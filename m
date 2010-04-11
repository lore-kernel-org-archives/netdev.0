From: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Subject: Re: HFSC classes going out of bounds, regression in recent kernels?
Date: Sun, 11 Apr 2010 05:10:06 +0300
Message-ID: <201004110510.06162.nuclearcat@nuclearcat.com>
References: <201004061822.21735.nuclearcat@nuclearcat.com> <4BBB5543.40607@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:32775 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135Ab0DKCLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Apr 2010 22:11:37 -0400
In-Reply-To: <4BBB5543.40607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 06 April 2010 18:37:39 Patrick McHardy wrote:
> Denys Fedorysychenko wrote:
> > I notice on one of my QoS machines that HFSC start going out of bandwidth
> > limits. The most terrible thing - it happens suddenly, and if i just
> > relaunch QoS script - everything will work fine.
> 
> That sounds like there's an overflow somewhere.
> 
> > I'm not sure it is not my mistake, but most probably it is a bug.
> > I can't tell for sure when it is happened, last kernel was on this
> > machine 2.6.28 i guess, or maybe even older.
> 
> Looking through the recent patches in this area, my prime suspect
> is the attached patch. Does reverting it make any difference?
> 
Hi, i made sure - bug not related to this patch. I try to patch (also had to 
test latest stable release, to make sure it is appearing on it), and each test 
taking 1 day. If i "restart" script to resetup HFSC - it works for a while 
fine. At next day, peak time period - it goes wild.

There is another thing also, i am going to try now, old kernel was 64-bit, but 
now 32bit, so i will try to shift to 64bit again.

It can be not regression, but a bug. I guess not many people use HFSC, even it 
is definitely better than HTB. Or i'm wrong?
