From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next] mac80211: silent build warnings
Date: Fri, 9 Jan 2015 09:00:42 +0800
Message-ID: <54AF283A.5020104@windriver.com>
References: <1420700655-9427-1-git-send-email-ying.xue@windriver.com> <54AE7F3F.3070802@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48065 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbbAIBAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 20:00:50 -0500
In-Reply-To: <54AE7F3F.3070802@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2015 08:59 PM, Sergei Shtylyov wrote:
> Hello.
>=20
> On 1/8/2015 10:04 AM, Ying Xue wrote:
>=20
>> Silent the following build warnings:
>=20
>> net/mac80211/mlme.c: In function =E2=80=98ieee80211_rx_mgmt_beacon=E2=
=80=99:
>> net/mac80211/mlme.c:1348:3: warning: =E2=80=98pwr_level_cisco=E2=80=99=
 may be used
>> uninitialized in this function [-Wuninitialized]
>> net/mac80211/mlme.c:1315:6: note: =E2=80=98pwr_level_cisco=E2=80=99 =
was declared here
>=20
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>> ---
>>   net/mac80211/mlme.c |    2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>=20
>> diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
>> index 2c36c47..13b5506 100644
>> --- a/net/mac80211/mlme.c
>> +++ b/net/mac80211/mlme.c
>> @@ -1312,7 +1312,7 @@ static u32 ieee80211_handle_pwr_constr(struct
>> ieee80211_sub_if_data *sdata,
>>   {
>>       bool has_80211h_pwr =3D false, has_cisco_pwr =3D false;
>>       int chan_pwr =3D 0, pwr_reduction_80211h =3D 0;
>> -    int pwr_level_cisco, pwr_level_80211h;
>> +    int pwr_level_cisco =3D 0, pwr_level_80211h =3D 0;
>=20
>    OK, but why are you also initializing the second variable?
>=20

Although the second variable is not warned in above compile warning
message, but it should be if we take a look at the code associated with=
 it.

However, as Johannes confirmed, the first change is unnecessary at all.
So please ignore the patch.

Thanks,
Ying

> WBR, Sergei
>=20
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
