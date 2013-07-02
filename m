From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: cdc_ether: allow combined control and data
 interface
Date: Tue, 02 Jul 2013 01:48:00 -0700 (PDT)
Message-ID: <20130702.014800.69165045741799552.davem@davemloft.net>
References: <1372500186-23567-1-git-send-email-bjorn@mork.no>
	<1422740.WTESdOQgPZ@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn@mork.no, netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	mrkiko.rs@gmail.com
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932489Ab3GBIsA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 04:48:00 -0400
In-Reply-To: <1422740.WTESdOQgPZ@linux-5eaq.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Oliver Neukum <oliver@neukum.org>
Date: Tue, 02 Jul 2013 10:17:51 +0200

> On Saturday 29 June 2013 12:03:06 Bj=F8rn Mork wrote:
>> Some Icera based Huawei modems handled by this driver are not
>> completely CDC ECM compliant, using the same USB interface for both
>> control and data. The CDC functional descriptors include a Union
>> naming this interface as both master and slave, so it is supportable
>> by relaxing the descriptor parsing in case these interfaces are
>> identical.
>>=20
>> This has been tested on a Huawei K3806 and verified to add support
>> for that device.
>>=20
>> Reported-and-tested-by: Enrico Mioso <mrkiko.rs@gmail.com>
>> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
> Acked-by: Oliver Neukum <oliver@neukum.org>

Applied, thanks for the review Oliver.
