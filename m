From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] Net: mac802154: comparing issue by type cast, finding
 by EXTRA_CFLAGS=-W
Date: Tue, 23 Apr 2013 09:11:24 +0800
Message-ID: <5175DFBC.7040000@asianux.com>
References: <5174DB87.3010908@asianux.com> <51754485.6040708@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	David Miller <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:40114 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967Ab3DWBML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 21:12:11 -0400
In-Reply-To: <51754485.6040708@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B404=E6=9C=8822=E6=97=A5 22:09, Sergei Shtylyov wrote:
>=20
>> Signed-off-by: Chen Gang <gang.chen@asianux.com>
>> ---
>>   net/mac802154/mac802154.h |    2 +-
>>   1 files changed, 1 insertions(+), 1 deletions(-)
>=20
>> diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
>> index 5c9e021..c59309f 100644
>> --- a/net/mac802154/mac802154.h
>> +++ b/net/mac802154/mac802154.h
>> @@ -88,7 +88,7 @@ struct mac802154_sub_if_data {
>>
>>   #define mac802154_to_priv(_hw)    container_of(_hw, struct
>> mac802154_priv, hw)
>>
>> -#define MAC802154_CHAN_NONE        (~(u8)0) /* No channel is assign=
ed */
>> +#define MAC802154_CHAN_NONE        (0xff) /* No channel is assigned=
 */
>=20
>    () not needed now.
>=20
> WBR, Sergei
>=20
>=20

  ok, thanks.  I will send patch v2

--=20
Chen Gang

Asianux Corporation
