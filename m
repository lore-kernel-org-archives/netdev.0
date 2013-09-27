From: Jon Maloy <maloy@donjonn.com>
Subject: Re: [PATCH net-next 1/5] tipc: silence sparse warnings
Date: Fri, 27 Sep 2013 06:25:07 -0400
Message-ID: <52455D03.6030308@donjonn.com>
References: <1380014868-2797-1-git-send-email-jon.maloy@ericsson.com> <1380014868-2797-2-git-send-email-jon.maloy@ericsson.com> <20130927.015908.1293107524454870319.davem@davemloft.net> <52453B51.5070702@windriver.com> <52453E8D.2020705@ericsson.com> <52455471.8060102@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Andreas_Bofj=E4ll?= <andreas.bofjall@ericsson.com>,
	jon.maloy@ericsson.com, netdev@vger.kernel.org,
	paul.gortmaker@windriver.com, erik.hugne@ericsson.com,
	tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm35-vm5.bullet.mail.bf1.yahoo.com ([72.30.238.77]:45879 "EHLO
	nm35-vm5.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751023Ab3I0Kac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 06:30:32 -0400
In-Reply-To: <52455471.8060102@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2013 05:48 AM, Ying Xue wrote:
> On 09/27/2013 04:15 PM, Andreas Bofj=E4ll wrote:
>> On 09/27/2013 10:01 AM, Ying Xue wrote:
>>> Good point!
>>> It's better for us to use memcpy_fromiovecend() instead of
>>> skb_copy_to_linear_data() and its friends.
>>>
>>> We will submit another version to correct this error soon.
Can you fix this asap, so I can re-post it? And, let's continue the thr=
ead
in tipc-discussion only until we (incl Paul) are happy with this patch.

///jon

>> I could be wrong here, but I think you should also remove the entire
>> cast on line 1210 in link.c:
>>
>> sect_crs =3D msg_sect[curr_sect].iov_base;
>>
>> There should be no reason to cast there since you made sect_crs into
>> const unchar* __user and msg_sect[].iov_base is void* __user.
>>
> You are right, thank you for your nice reminder!
>
> Regards,
> Ying
>
>> /Andreas
>>
>>
