From: VinX <vincenx@fastwebnet.it>
Subject: Re: tiacx module fail
Date: Mon, 11 Sep 2006 15:08:47 +0200
Message-ID: <45055FDF.2000900@fastwebnet.it>
References: <4503F640.3040300@fastwebnet.it> <20060911122541.GA4537@kiopa.cmartin.tk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from aa003msr.fastwebnet.it ([85.18.95.66]:7358 "EHLO
	aa003msr.fastwebnet.it") by vger.kernel.org with ESMTP
	id S1751475AbWIKNQV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 09:16:21 -0400
Received: from theconfessional.redirectme.net (23.251.157.101) by aa003msr.fastwebnet.it (7.2.070.1)
        id 44FEFCAE002DBBCE for netdev@vger.kernel.org; Mon, 11 Sep 2006 15:16:20 +0200
Received: from [192.168.1.144] (unknown [192.168.0.50])
	by theconfessional.redirectme.net (Postfix) with ESMTP id CC02338E663
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 14:46:45 +0200 (CEST)
To: netdev@vger.kernel.org
In-Reply-To: <20060911122541.GA4537@kiopa.cmartin.tk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Carlos Mart=EDnn Nieto wrote:
>  The error message says it is trying to scan with eth1, but the drive=
r
> log says the card is on wlan0.
>=20
>  Try doing `iwlist wlan0 scan`. That should work.
No.
The first dmesg is about tiacx module, this module set the name of my
wireless card as eth1, but with acx module set wlan0 (second dmesg).
--
vinTux ~ # cat /proc/net/dev |grep -v \| |cut -d\: -f1
    lo
  eth0
 wlan0
vinTux ~ # lsmod |grep ^acx|awk '{print $1}'
acx
vinTux ~ #
--
but with tiacx module i have:
--
vinTux ~ # cat /proc/net/dev |grep -v \| |cut -d\: -f1
    lo
  eth0
  eth1
vinTux ~ # lsmod |grep ^acx|awk '{print $1}'
acx_pci
acx_common
vinTux ~ #
--

I try `iwlist wlan0 scanning' but i have same result.

Regards
VinX
