From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH net-next-2.6 v2 1/2] can: add driver for Softing card
Date: Mon, 10 Jan 2011 15:05:57 +0100
Message-ID: <4D2B1245.9060303@grandegger.com>
References: <20110104150513.GA321@e-circ.dyndns.org>	<20110104150759.GB321@e-circ.dyndns.org>	<4D24DB2C.9040104@grandegger.com> <20110110133112.GA324@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:48460 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457Ab1AJOEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 09:04:21 -0500
In-Reply-To: <20110110133112.GA324@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2011 02:31 PM, Kurt Van Dijck wrote:
> Wolfgang,
> 
> A few thoughts ...
> 
> On Wed, Jan 05, 2011 at 09:57:16PM +0100, Wolfgang Grandegger wrote:
>>>  
>>>  obj-y				+= usb/
>>> +obj-y				+= softing/
>>
>> Please use "obj-$(CONFIG_CAN_SOFTING)" here.
> As I explained, softing does not depend on softing_cs or vice versa,
> which makes "obj-$(CONFIG_CAN_SOFTING)" not right.

OK, another good reason to make softing_cs depend on CONFIG_CAN_SOFTING.
Does it make sense to compile softing_cs without CONFIG_CAN_SOFTING for
the *real* user?

...

>>> +	priv->can.ctrlmode_supported =
>>> +		CAN_CTRLMODE_3_SAMPLES;/* | CAN_CTRLMODE_BERR_REPORTING */;
>>
>> Hm, any chance to support CAN_CTRLMODE_BERR_REPORTING? If not, please
>> remove the comment.
> 
> I think I better try to write it properly without, and add error reporting
> later, after serious testing of the error reporting on a softing card.

OK, then just cleanup properly.

> The primary goal now is get this driver in mainline kernel since PCMCIA
> has been changing recently, and I found it hard to keep up. So, first things
> first ...

Fine for me. You can then add my:

Acked-by: Wolfgang Grandegger <wg@grandegger.com>

Thanks.

Wolfgang.
