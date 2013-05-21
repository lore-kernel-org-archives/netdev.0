From: Fan Du <fan.du@windriver.com>
Subject: Re: [RESEND PATCH net-next] xfrm: add LINUX_MIB_XFRMACQUIREERROR
 statistic counter
Date: Tue, 21 May 2013 09:22:24 +0800
Message-ID: <519ACC50.5030402@windriver.com>
References: <1369014025-19564-1-git-send-email-fan.du@windriver.com> <519A2F1A.3010703@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <steffen.klassert@secunet.com>, <herbert@gondor.hengli.com.au>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:44897 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755916Ab3EUBYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 21:24:06 -0400
In-Reply-To: <519A2F1A.3010703@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Sergei

On 2013=E5=B9=B405=E6=9C=8820=E6=97=A5 22:11, Sergei Shtylyov wrote:
> Hello.
>
> On 20-05-2013 5:40, Fan Du wrote:
>
>> When host ping its peer, ICMP echo request packet triggers IPsec
>> policy, then host negotiates SA secret with its peer. After IKE
>> installed SA for OUT direction, but before SA for IN direction
>> installed, host get ICMP echo reply from its peer. At the time
>> being, the SA state for IN direction could be XFRM_STATE_ACQ,
>> then the received packet will be dropped after adding
>> LINUX_MIB_XFRMINSTATEINVALID statistic.
>
>> Adding a LINUX_MIB_XFRMACQUIREERROR statistic counter for such
>> scenario when SA in larval state is much clearer for user than
>> LINUX_MIB_XFRMINSTATEINVALID which indicates the SA is totally
>> bad.
>
>> Signed-off-by: Fan Du <fan.du@windriver.com>
>> ---
>> include/uapi/linux/snmp.h | 1 +
>> net/xfrm/xfrm_input.c | 5 +++++
>> net/xfrm/xfrm_proc.c | 1 +
>> 3 files changed, 7 insertions(+), 0 deletions(-)
>
>> diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
>> index df2e8b4..3d072bf 100644
>> --- a/include/uapi/linux/snmp.h
>> +++ b/include/uapi/linux/snmp.h
>> @@ -287,6 +287,7 @@ enum
>> LINUX_MIB_XFRMOUTPOLERROR, /* XfrmOutPolError */
>> LINUX_MIB_XFRMFWDHDRERROR, /* XfrmFwdHdrError*/
>> LINUX_MIB_XFRMOUTSTATEINVALID, /* XfrmOutStateInvalid */
>> + LINUX_MIB_XFRMACQUIREERROR, /* XfrmAcquireError*/
>
> Please indent the comment with tabs and align with the above ones.

Thanks for the point, I will fix this in next round after reviewing fro=
m Steffen and others.

> WBR, Sergei
>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
