From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 module problem with suspend2
Date: Sun, 30 Jul 2006 00:41:08 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093F9F6@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <BAY112-F336CA977B6253ACECC0386F0590@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Suspend2-devel@lists.suspend2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:11275 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751237AbWG3HlQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 03:41:16 -0400
Content-class: urn:content-classes:message
In-Reply-To: <BAY112-F336CA977B6253ACECC0386F0590@phx.gbl>
To: "Lamarque Souza" <lamarque_souza@hotmail.com>,
	netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lamarque Souza wrote:

> I have this problem since I first tried to use suspend. The 
> first kernel I 
> tried was 2.6.13 I guess.  Since that time I reload the 
> driver, then I do 
> not know if it works with kernel 2.6.14, 2.6.15 or 2.6.16 
> without reloading.
> 

I just tried SOFTWARE_SUSPEND on 2.6.17 and that seems to
work ok.  I was able to suspend to RAM, and upon wakeup,
even though video never came back, I was able to ping to
that machine.  This tells me that suspend/resume are working
fine on tg3.

If I have time I'll try SUSPEND2 but it should be the same
as far as tg3 is concerned.  Have you had success suspending
another non-tg3 NIC on your system?

