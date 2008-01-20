From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: ESFQ (or SFQ updates) mainline status?
Date: Sat, 19 Jan 2008 20:50:13 -0800
Message-ID: <20080119205013.61294ad3@deepthought>
References: <1199474475.3820.65.camel@sally>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:54337 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753288AbYATExd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jan 2008 23:53:33 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JGSBQ-0005m0-GS
	for netdev@vger.kernel.org; Sun, 20 Jan 2008 04:53:24 +0000
Received: from 069-064-229-129.pdx.net ([69.64.229.129])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 04:53:24 +0000
Received: from shemminger by 069-064-229-129.pdx.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 04:53:24 +0000
In-Reply-To: <1199474475.3820.65.camel@sally>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 04 Jan 2008 11:21:15 -0800
Jeff Gustafson <ncjeffgus@zimage.com> wrote:

> Hi all,
> 	I have a question about the status of the spiffy updates to SFQ.  I
> *really* like the ESFQ idea.  I appears to be exactly what I'm looking
> for.  From what I can tell from this mailing list, SFQ is getting some
> or all of the ESFQ features.  Although the ESFQ web site gives detailed
> information about the status for inclusion in mainline, I am having
> trouble finding out exactly what (if any) parts of ESFQ got into SFQ in
> mainline.
> 	Did any of the ESFQ-like enhancements for SFQ reach .23 or do I still
> need to patch?  I am running a stripped-down Fedora 8 box and it would
> be very convenient if the patches were already in .23 or added by the
> Fedora team.
> 	I tried to run the ESFQ command against SFQ, but the command was
> rejected:
> 
> /sbin/tc qdisc add dev eth1 parent 1:12 handle 12: sfq perturb 10 hash
> ctnatchg
> 
> 	It appears the even if the kernel does have the patches, the shipped
> version tc does not.
> 
> 				..Jeff

The mainline kernel doesn't have ESFQ, so the distribute version of iproute2
does not. If your distro chooses to add ESFQ to their kernel, then they
need to extend tc as well.


-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

