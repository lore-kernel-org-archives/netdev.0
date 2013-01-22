From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net] net: cdc_ncm: workaround for missing CDC Union
Date: Tue, 22 Jan 2013 11:35:48 +0100
Message-ID: <87d2wxa4jf.fsf@nemi.mork.no>
References: <1358519147-10073-1-git-send-email-bjorn@mork.no>
	<2214944.HMNV73jJm5@linux-5eaq.site> <87ip6qy2q7.fsf@nemi.mork.no>
	<6132136.Whp52cipJH@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko@gmail.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Greg Suarez <gsuarez@smithmicro.com>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53923 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750723Ab3AVKgi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 05:36:38 -0500
In-Reply-To: <6132136.Whp52cipJH@linux-5eaq.site> (Oliver Neukum's message of
	"Tue, 22 Jan 2013 09:50:39 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.de> writes:
> On Monday 21 January 2013 16:28:48 Bj=C3=B8rn Mork wrote:
>
>> Agreed.  But I believe the condition should be=20
>>=20
>>  if (!(info->flags & FLAG_SEND_ZLP) && !(info->flags & FLAG_MULTI_PA=
CKET)) {
>>      ..
>>  } else {
>>      urb->transfer_flags |=3D URB_ZERO_PACKET;
>>  }
>>=20
>> to ensure that we send the ZLP in this case.
>
> Why? If a driver wants ZLP, it can set FLAG_SEND_ZLP. Your proposed c=
hange
> would take away an option from drivers without any gain.

OK.


Bj=C3=B8rn
