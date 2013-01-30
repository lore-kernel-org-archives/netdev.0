From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: usbnet: prevent buggy devices from killing
 us
Date: Wed, 30 Jan 2013 17:36:33 -0500 (EST)
Message-ID: <20130130.173633.1911213197565689159.davem@davemloft.net>
References: <1359453088-12370-1-git-send-email-bjorn@mork.no>
	<1784756.y7ETz6QMlb@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn@mork.no, netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	joe@perches.com
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122Ab3A3Wgh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 17:36:37 -0500
In-Reply-To: <1784756.y7ETz6QMlb@linux-5eaq.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Oliver Neukum <oliver@neukum.org>
Date: Wed, 30 Jan 2013 08:44:35 +0100

> On Tuesday 29 January 2013 10:51:28 Bj=F8rn Mork wrote:
>> A device sending 0 length frames as fast as it can has been
>> observed killing the host system due to the resulting memory
>> pressure.
>>=20
>> Temporarily disable RX skb allocation and URB submission when
>> the current error ratio is high, preventing us from trying to
>> allocate an infinite number of skbs.  Reenable as soon as we
>> are finished processing the done queue, allowing the device
>> to continue working after short error bursts.
>>=20
>> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
> Acked-by: Oliver Neukum <oneukum@suse.de>

Applied, thanks.
