From: Dan Williams <dcbw@redhat.com>
Subject: Re: Abour linux driver supports BCM4325
Date: Fri, 21 Aug 2009 08:13:01 -0500
Message-ID: <1250860381.2876.19.camel@localhost.localdomain>
References: <f42a38140908202319y5c352aa3s37fec67e5cb8d7a3@mail.gmail.com>
	 <f42a38140908202322ua3d4486meae6653044465583@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: feng tian <feng.of.tian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932087AbZHUNM5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 09:12:57 -0400
In-Reply-To: <f42a38140908202322ua3d4486meae6653044465583@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-08-21 at 14:22 +0800, feng tian wrote:
> Dear All,
> 
> We are working on a project which supports the BCM4325 linux wireless
> driver. The interface between the BCM chip and SOC(pxa310) is SDIO.
> I did some searches online and found that there is no available driver
> for this chip. Do I have to implement this myself? Is there anyone can
> provide us some related materials?  Thanks very much.

You'll probably want to ask on the linux-wireless list where the
wireless people hang out.  Partial answer: there is already a driver
(b43) for many of broadcom 802.11 devices, including some of the
"LP-PHY" devices.  This driver may or may not be suitable for the 4325
depending on the 4325's firmware interface.  The b43 driver is not yet
capable of using SDIO to communicate with the wifi chip, but that
appears to be what you are working on.  So I'd suggest posting to the
linux-wireless mailing list and seeing what the b43 driver people say.

http://linuxwireless.org/en/developers/MailingLists

Dan


