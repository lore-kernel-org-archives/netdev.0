From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: TCP Pacing
Date: Thu, 14 Sep 2006 06:30:24 +1200
Message-ID: <5640c7e00609131130m5e8b7e30x53c879d22a142d94@mail.gmail.com>
References: <200609121958.22820.root@danielinux.net>
	 <5640c7e00609121426t75f5519at562a85f40b64163@mail.gmail.com>
	 <200609131018.40023.root@danielinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Carlo Caini" <ccaini@deis.unibo.it>,
	"Rosario Firrincieli" <rfirrincieli@arces.unibo.it>,
	"Giovanni Pau" <gpau@cs.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-f131.google.com ([64.233.182.131]:52213 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S1750829AbWIMSa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 14:30:26 -0400
Received: by nf-out-f131.google.com with SMTP id l6so219425nfa
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 11:30:25 -0700 (PDT)
To: root@danielinux.net
In-Reply-To: <200609131018.40023.root@danielinux.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/13/06, Daniele Lacamera <root@danielinux.net> wrote:
> On Tuesday 12 September 2006 23:26, Ian McDonald wrote:
> > Where is the published research? If you are going to mention research
> > you need URLs to papers and please put this in source code too so
> > people can check.
>
> I added the main reference to the code. I am going to give you all the
> pointers on this research, mainly recent congestion control proposals
> that include pacing.

Thanks
>
> > I agree with Arnaldo's comments and also would add I don't like having
> > to select 1000 as HZ unit. Something is wrong if you need this as I
> > can run higher resolution timers without having to do this....
>
> I removed that select in Kconfig, I agree it doesn't make sense at all,
> for portability. However, pacing works with 1ms resolution, so maybe
> a "depends HZ_1000" is still required. (How do you run 1ms timers with
> HZ!=1000?)
>
The HZ refers to time slices per second mostly for user space - e.g.
how often to task switch.
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
