From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net] net: qmi_wwan: add ZTE MF60
Date: Thu, 05 Jul 2012 13:09:31 +0200
Message-ID: <87obnujwgk.fsf@nemi.mork.no>
References: <1341251597-21124-1-git-send-email-bjorn@mork.no>
	<20120705.031648.85978116859244029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:58340 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182Ab2GELJi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 07:09:38 -0400
In-Reply-To: <20120705.031648.85978116859244029.davem@davemloft.net> (David
	Miller's message of "Thu, 05 Jul 2012 03:16:48 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> Date: Mon,  2 Jul 2012 19:53:17 +0200
>
>> +static const struct driver_info	qmi_wwan_force_int2 =3D {
>
> Please get rid of that strange tab character and resubmit.

Sure. Will do.

Looks like a thoughtless copy-paste thing originally coming from
cdc_ether.  Funny thing is that it has survived several incarnations
already, as this specific instance came from a copy-paste within the
same driver.

It's all checkpatch'es fault for not warning me :-)

Luckily all of these will go away when the whitelisting is removed
(i.e. when the USB interface number matching in 3.6 is available).


Bj=C3=B8rn
