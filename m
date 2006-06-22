From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: [Bugme-new] [Bug 6735] New: network connection does not
	survive APM suspend and resume
Date: Thu, 22 Jun 2006 19:55:09 -0400
Message-ID: <1151020510.17952.14.camel@mindpipe>
References: <200606222339.k5MNdM7K007547@fire-2.osdl.org>
	 <20060622165440.3807e92c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, netdev@vger.kernel.org,
	rob.dyck@telus.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from viper.oldcity.dca.net ([216.158.38.4]:38601 "HELO
	viper.oldcity.dca.net") by vger.kernel.org with SMTP
	id S1161464AbWFVXy6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 19:54:58 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060622165440.3807e92c.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

How in the heck did I get on the CC list for this? ;-)

Lee

On Thu, 2006-06-22 at 16:54 -0700, Andrew Morton wrote:
> bugme-daemon@bugzilla.kernel.org wrote:
> >
> > http://bugzilla.kernel.org/show_bug.cgi?id=6735
> > 
> >            Summary: network connection does not survive APM suspend and
> >                     resume
> >
> > ...
> >
> > Steps to reproduce:Push button to suspend ( APM ), push button again to resume, 
> > network connection is lost.
> > 
> > Problem Description:The network connection will not survive suspend and resume.
> > Works correctly on 2.6.16.1. "/etc/rc.d/init.d/network restart" will restore 
> > the network. I tried compiling with the file via-rhine.c from 2.6.16.1 but it 
> > still fails. No error messages.
> 
> This is a post-2.6.16 regression.
> 
> It's probably unrelated to the device driver itself.
> 
> Can anyone suggest where we should be looking?
> 
> Thanks.
> 

