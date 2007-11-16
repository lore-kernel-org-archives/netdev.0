From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.24-rc2-mm1 -- strange apparent network failures
Date: Thu, 15 Nov 2007 16:44:41 -0800
Message-ID: <20071115164441.67a8e2df.akpm@linux-foundation.org>
References: <20071113175906.497a1a6a.akpm@linux-foundation.org>
	<20071115100209.GB2513@shadowen.org>
	<200711152028.29734.kjwinchester@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: apw@shadowen.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kamalesh@linux.vnet.ibm.com,
	Andrew Morgan <morgan@kernel.org>
To: Kevin Winchester <kjwinchester@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50324 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1765796AbXKPApf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 19:45:35 -0500
In-Reply-To: <200711152028.29734.kjwinchester@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Nov 2007 20:28:29 -0400
Kevin Winchester <kjwinchester@gmail.com> wrote:

> On November 15, 2007 06:02:09 am Andy Whitcroft wrote:
> > When testing some of the later 2.6.24-rc2-mm1+hotfix combinations on three
> > of our test systems one job from each batch (1/4) failed.  In each case the
> > machine appears to have booted normally all the way to a login: prompt.
> > However in the failed boots the networking though apparently initialised
> > completely and correctly (as far as I can tell from the console output), is
> > reported as not responding to ssh connections.  The network interface seems
> > to have been initialised on the right port, and the ssh daemons started.
> >
> > Two of the machines are powerpc boxes, the other an older x86_64.
> > One machine is 4/4 in testing, just one.  Most of the other machines are
> > still not able to compile this stack so do not contribute to our knowledge.
> >
> > Any ideas?
> >
> 
> I see this as well - the computer boots fine but no network.  The only clues 
> in the dmesg are:
> 
> [  294.097876] warning: process `dhclient' gets w/ old libcap
> [  294.097893] warning: process `dhclient' sets w/ old libcap
> 
> So I'll try backing up the patch series to before:
> 
> add-64-bit-capability-support-to-the-kernel.patch

Yes, that's a good one to suspect.

What a peculiar error message.

> or so, and see if that's the problem.  If anyone has any other ideas, let me 
> know.

