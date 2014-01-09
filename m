From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next 3/3] xfrm: Don't prohibit AH from using ESN feature
Date: Thu, 9 Jan 2014 19:09:11 +0800
Message-ID: <52CE8357.7030800@windriver.com>
References: <1389171192-28091-1-git-send-email-fan.du@windriver.com> <1389171192-28091-4-git-send-email-fan.du@windriver.com> <20140109105021.GY31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:42175 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754446AbaAILJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 06:09:34 -0500
In-Reply-To: <20140109105021.GY31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2014=E5=B9=B401=E6=9C=8809=E6=97=A5 18:50, Steffen Klassert wrote:
> On Wed, Jan 08, 2014 at 04:53:12PM +0800, Fan Du wrote:
>> Clear checking when user try to use ESN through netlink keymgr for A=
H.
>>
>> Signed-off-by: Fan Du<fan.du@windriver.com>
>> ---
>>   net/xfrm/xfrm_user.c |    4 ----
>>   1 file changed, 4 deletions(-)
>>
>> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
>> index 97681a3..f362a78 100644
>> --- a/net/xfrm/xfrm_user.c
>> +++ b/net/xfrm/xfrm_user.c
>> @@ -141,10 +141,6 @@ static inline int verify_replay(struct xfrm_use=
rsa_info *p,
>>
>>   	if (!rt)
>>   		return 0;
>> -
>> -	if (p->id.proto !=3D IPPROTO_ESP)
>> -		return -EINVAL;
>> -
>
> You can not change this as long as AH for ipv6 does not
> support ESN. Please provide the ipv6 side too.
>
> Also, simply removing this check is wrong in any case.
> You have to make sure that we catch if someone tries
> to insert an ESN state for other unsupported protocols,
> like ipcomp.
>

Sure, will add IPv6 support soon :)

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
