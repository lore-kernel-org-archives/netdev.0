From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [RFC] driver adjusts qlen, increases CPU
Date: Fri, 4 Aug 2006 14:07:48 -0700
Message-ID: <4807377b0608041407r3d27805aw649b4103bca97614@mail.gmail.com>
References: <Pine.WNT.4.63.0605100905150.1804@jbrandeb-desk.amr.corp.intel.com>
	 <44D39539.5040805@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jesse Brandeburg" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:6176 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1161462AbWHDVHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 17:07:50 -0400
Received: by ug-out-1314.google.com with SMTP id m3so194338ugc
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2006 14:07:48 -0700 (PDT)
To: "Rick Jones" <rick.jones2@hp.com>
In-Reply-To: <44D39539.5040805@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/4/06, Rick Jones <rick.jones2@hp.com> wrote:
> > Problem we've seen is that setting this shorter queue causes a large spike
> > in cpu when transmitting using UDP:
> >
> > 100Mb/s link
> > txqueuelen: 1000 Throughput: 92.44 CPU: 5.00
> > txqueuelen: 100 Throughput: 93.80 CPU: 61.59
> >
> > Is this expected? any comments?
>
> Triggering intra-stack flow-control perhaps?  Perhaps 10X more often
> than before if the queue is 1/10th what it was before?

yes, that is my guess too, lock thrash coming into and out of qdisc full?

> Out of curiousity, how does the UDP socket's SO_SNDBUF compare to the
> queue depth?

forgive my ignorance, how do i measure that?

Jesse
