From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Wed, 15 Sep 2010 14:11:06 +0200
Message-ID: <4C90B7DA.6030405@grandegger.com>
References: <4C61EDE5.4030505@dsn.okisemi.com>	<4C629FE5.6000204@pengutronix.de>	<005f01cb533e$5c21d530$66f8800a@maildom.okisemi.com>	<4C8E1918.5000007@pengutronix.de>	<003a01cb53a6$4ca724d0$66f8800a@maildom.okisemi.com>	<4C9078D3.50300@grandegger.com> <4C909518.5010309@hartkopp.net> <4C90A60E.5040900@grandegger.com> <4C90B63D.9030201@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	andrew.chih.howe.khor@intel.com, socketcan-core@lists.berlios.de,
	qi.wang@intel.com, netdev@vger.kernel.org, gregkh@suse.de,
	yong.y.wang@intel.com, Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	Morinaga <morinaga526@dsn.okisemi.com>, meego-dev@meego.com,
	arjan@linux.intel.com
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:46494 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002Ab0IOMKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 08:10:22 -0400
In-Reply-To: <4C90B63D.9030201@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2010 02:04 PM, Marc Kleine-Budde wrote:
> On 09/15/2010 12:55 PM, Wolfgang Grandegger wrote:
>>> Just a remark:
>>>
>>> During the IDF the informations about the Topcliff Controller Hub have been
>>> reworked, so that some of the documentation became available for the public:
>>>
>>> http://edc.intel.com/Platforms/Atom-E6xx/#hardware
>>>
>>> Especially the Datasheet for the Platform Controller Hub EG20T can be found:
>>>
>>> http://download.intel.com/embedded/chipsets/datasheet/324211.pdf
>>>
>>> In chapter 13 there are some details about the CAN controller.
>>
>> Ah, thanks for the link. The CAN controller seems then to be similar to
>> the OKI MSM9225B.
> 
> According to the datasheet for the msm9225 I found, the chip has got an
> 8 bit interface (mmap'ed or spi). The Intel is 32 bit based (most, maybe
> all, upper 16 bit are marked as reserverd).

I said *similar*, especially in respect to ability of combining RX
message objects to a fifo.

Wolfgang.

