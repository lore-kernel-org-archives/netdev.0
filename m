From: Igor Widlinski <igor.widlinski@eigendev.com>
Subject: Re: tg3 driver not advertising 1000mbit
Date: Tue, 23 Jun 2009 18:21:20 +0000 (UTC)
Message-ID: <loom.20090623T181758-637@post.gmane.org>
References: <4A32D3DB.30703@dupondje.be> <C27F8246C663564A84BB7AB343977242178EE78063@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:57795 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424AbZFWSZE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2009 14:25:04 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1MJAg3-0007D9-8s
	for netdev@vger.kernel.org; Tue, 23 Jun 2009 18:25:03 +0000
Received: from 24.85.224.244 ([24.85.224.244])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 23 Jun 2009 18:25:03 +0000
Received: from igor.widlinski by 24.85.224.244 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 23 Jun 2009 18:25:03 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan <mchan <at> broadcom.com> writes:

> 
> Jean-Louis Dupond wrote:
> 
> > I surely tried other cables. But its surely not the cable because:
> > 1) We tried other cables
> > 2) After a reboot it works, or after a mii-tool -R
> > 3) We have this issue on like +100 servers :(
> >
> > The servers are connected on a Dell PowerConnect 6248 switch.
> >
> 
> I'll ask our lab to test this.  Thanks.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo <at> vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


We just noticed a similar issue on one of our servers (Dell R300, with BCM5722
Ethernet card). It is connected to 3 com 4200g switch.

We switched the cables in the morning, and the same issue still exists. Will
reboot sometime next week. Hopefully that fixes things.

