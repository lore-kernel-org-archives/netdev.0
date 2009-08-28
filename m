From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] net-next:can: add TI CAN (HECC) driver
Date: Fri, 28 Aug 2009 15:27:49 +0200
Message-ID: <4A97DB55.2000100@hartkopp.net>
References: <1251458282-4674-1-git-send-email-anantgole@ti.com> <4A97D146.5050806@hartkopp.net> <2A3DCF3DA181AD40BDE86A3150B27B6B02F6211049@dbde02.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "socketcan-core@lists.berlios.de" <socketcan-core@lists.berlios.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wolfgang Grandegger <wg@grandegger.com>
To: "Gole, Anant" <anantgole@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:36498 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbZH1N1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 09:27:51 -0400
In-Reply-To: <2A3DCF3DA181AD40BDE86A3150B27B6B02F6211049@dbde02.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gole, Anant wrote:

>>> +#include <linux/can/platform/ti_hecc_platform.h>
>> Please use
>>
>> linux/can/platform/ti_hecc.c
> 
> are you suggesting to keep the platform file name as ti_hecc.h?
> 

Yep!

We currently have

linux/can/platform/sja1000.h
linux/can/platform/mcp251x.h

there. And as you need the full path for the include anyway, we decided to put
these CAN specific platform includes in linux/can/platform.

Else we would end with tons of <drivername>_platform.h in linux/can where we
have all the common stuff for CAN networking layer, etc.

Regards,
Oliver
