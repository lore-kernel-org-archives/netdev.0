From: bora.sahin@ttnet.net.tr
Subject: Re: [PATCH 2/12] smc911x: Fix SMC_WRITE_EEPROM_CMD macro
Date: Thu, 21 Sep 2006 14:51:13 +0300
Message-ID: <200609211451.14067.bora.sahin@ttnet.net.tr>
References: <OFAEF14D11.7E5DA419-ON802571E9.006B70D9-802571E9.006CBCEF@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="Iso-8859-9"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, romieu@fr.zoreil.com,
	dustin@sensoria.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:34903 "EHLO
	fep04.ttnet.net.tr") by vger.kernel.org with ESMTP id S1751121AbWIULqx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 07:46:53 -0400
To: Steve.Glendinning@smsc.com
In-Reply-To: <OFAEF14D11.7E5DA419-ON802571E9.006B70D9-802571E9.006CBCEF@smsc.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Send again with this time to netdev also. I didnt notice Steve not including 
netdev in the first place.

> Hi Francois/Bora,
>
> > > Macro abuse. It should be a function.
> >
> > Yes but I got smc911x.h and smc91x.h as a basis. In the smc911x.c
> > there are macros which is longer than it, e.g. SMC_GET_MII. In the
> > same way, smc91x.h contains even more longer like SMC_PUSH_DATA.
> > But, of course, it doesnt mean they are correct.
>
> At SMSC (with help from ARM) we tidied up and posted our smsc911x driver
> to the netdev list.  This uses a more "2.6" style, supports more devices,
> contains additional workarounds for hardware issues and works on !arm.
>
> I don't think Jeff has included this in 2.6 yet, so let me know if you
> would like a copy.

I tracked your mails from archives. Well, as said, which one will be stay at 
the kernel, Dustin's or SMSC's? Because I have additional patches againist to 
in-kernel driver and maybe some more in the future. Our board is MIPS based.

PS: I am happy if you send me your patches privately...

--
Bora SAHIN
