From: "Heise, Peter" <peter.heise@airbus.com>
Subject: AW: [PATCH net-next] net/hsr: Added support for HSR v1
Date: Wed, 20 Apr 2016 07:10:28 +0000
Message-ID: <28805_1461136234_57172B6A_28805_14792_1_01b784c4ce1945e28da3d3dd423a56a9@DE0-03DAG07-P04.central.mail.corp>
References: <20160413115222.GA42572@aircraft-controller>
	<20160419082100.237f1b6e@xeon-e3>
 <8104_1461082351_571658EF_8104_4642_1_20160419.121227.1437003570791513649.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "arvid.brodin@alten.se" <arvid.brodin@alten.se>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"sd@queasysnail.net" <sd@queasysnail.net>,
	"henrik@austad.us" <henrik@austad.us>,
	"nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"dsa@cumulusnetworks.com" <dsa@cumulusnetworks.com>,
	"eranbe@mellanox.com" <eranbe@mellanox.com>,
	"ast@plumgrid.com" <ast@plumgrid.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from airbus-sf10.airbus.gmessaging.net ([81.252.56.26]:55795 "EHLO
	airbus-sf10.airbus.gmessaging.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753365AbcDTHQu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 03:16:50 -0400
In-Reply-To: <8104_1461082351_571658EF_8104_4642_1_20160419.121227.1437003570791513649.davem@davemloft.net>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the advice Stephen, new patch submitted!


-----Urspr=FCngliche Nachricht-----
Von: David Miller [mailto:davem@davemloft.net]=20
Gesendet: Dienstag, 19. April 2016 18:12
An: stephen@networkplumber.org
Cc: mail@pheise.de; arvid.brodin@alten.se; hannes@stressinduktion.org; =
sd@queasysnail.net; henrik@austad.us; nikolay@cumulusnetworks.com; tgra=
f@suug.ch; linville@tuxdriver.com; gospo@cumulusnetworks.com; dsa@cumul=
usnetworks.com; eranbe@mellanox.com; ast@plumgrid.com; netdev@vger.kern=
el.org; Heise, Peter
Betreff: Re: [PATCH net-next] net/hsr: Added support for HSR v1

=46rom: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 19 Apr 2016 08:21:00 -0700

> On Wed, 13 Apr 2016 13:52:22 +0200
> Peter Heise <mail@pheise.de> wrote:
>=20
>> diff --git a/include/uapi/linux/if_link.h=20
>> b/include/uapi/linux/if_link.h index 9427f17..bb3a90b 100644
>> --- a/include/uapi/linux/if_link.h
>> +++ b/include/uapi/linux/if_link.h
>> @@ -773,6 +773,7 @@ enum {
>>  	IFLA_HSR_SLAVE1,
>>  	IFLA_HSR_SLAVE2,
>>  	IFLA_HSR_MULTICAST_SPEC,	/* Last byte of supervision addr */
>> +	IFLA_HSR_VERSION,		/* HSR version */
>>  	IFLA_HSR_SUPERVISION_ADDR,	/* Supervision frame multicast addr */
>>  	IFLA_HSR_SEQ_NR,
>=20
> You added a new value into the middle of an enumeration field.
> This breaks kernel ABI. Older applications (like iproute) would see=20
> the wrong values.
>=20
> Please submit a new change which moves HSR_VERSION to the end of the=20
> enum

Good catch, Stephen.

This mail has originated outside your organization, either from an exte=
rnal partner or the Global Internet.
Keep this in mind if you answer this message.



The information in this e-mail is confidential. The contents may not be=
 disclosed or used by anyone other than the addressee. Access to this e=
-mail by anyone else is unauthorised.
If you are not the intended recipient, please notify Airbus immediately=
 and delete this e-mail.
Airbus cannot accept any responsibility for the accuracy or completenes=
s of this e-mail as it has been sent over public networks. If you have =
any concerns over the content of this message or its Accuracy or Integr=
ity, please contact Airbus immediately.
All outgoing e-mails from Airbus are checked using regularly updated vi=
rus scanning software but you should take whatever measures you deem to=
 be appropriate to ensure that this message and any attachments are vir=
us free.
