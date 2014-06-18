From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next v2 1/3] ieee802154: cc2520: adds driver for TI
 CC2520 radio
Date: Wed, 18 Jun 2014 16:43:06 +0530
Message-ID: <53A17442.8010009@gmail.com>
References: <1403068565-32224-1-git-send-email-varkab@cdac.in> <1403068565-32224-2-git-send-email-varkab@cdac.in> <20140618091010.GB26461@leverpostej> <53A15B38.6060404@gmail.com> <20140618095519.GE26461@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"alex.bluesman.smirnov@gmail.com" <alex.bluesman.smirnov@gmail.com>,
	"dbaryshkov@gmail.com" <dbaryshkov@gmail.com>,
	"linux-zigbee-devel@lists.sourceforge.net"
	<linux-zigbee-devel@lists.sourceforge.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Varka Bhadram <varkab@cdac.in>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:61752 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965376AbaFRLOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 07:14:04 -0400
In-Reply-To: <20140618095519.GE26461@leverpostej>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2014 03:25 PM, Mark Rutland wrote:
> On Wed, Jun 18, 2014 at 10:26:16AM +0100, Varka Bhadram wrote:
>> +static int cc2520_probe(struct spi_device *spi)
>> +{
>> +       struct cc2520_private *priv;
>> +       struct pinctrl *pinctrl;
>> +       struct cc2520_platform_data *pdata;
>> +       struct device_node __maybe_unused *np =3D spi->dev.of_node;
>>
>> This looks to be definitely unused rather than __maybe_unused. There=
 are
>> no other occuences of "np" in this function.
>>
>> This macro defined like this.
>> #define __maybe_unused  __attribute__((unused))
> Sure, but that's irrelevant. There's absolutely no point in this
> variable existing at all, and it can simply disappear.
>
> Mark.

If we don't use that macro the compiler triggers warnings saying that: =
 warning: unused variable =91np=92 [-Wunused-variable]


Varka Bhadram
