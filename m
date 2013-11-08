From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next v2 2/3] net_sched: fix some checkpatch errors
Date: Fri, 08 Nov 2013 12:04:16 +0100
Message-ID: <87ob5vf93j.fsf@nemi.mork.no>
References: <1383790412-41944-1-git-send-email-yangyingliang@huawei.com>
	<1383790412-41944-3-git-send-email-yangyingliang@huawei.com>
	<527B5160.5070700@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yang Yingliang <yangyingliang@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org, eric.dumazet@gmail.com, jhs@mojatatu.com,
	stephen@networkplumber.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43987 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757116Ab3KHLGC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 06:06:02 -0500
In-Reply-To: <527B5160.5070700@redhat.com> (Daniel Borkmann's message of "Thu,
	07 Nov 2013 09:37:52 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann <dborkman@redhat.com> writes:
> On 11/07/2013 03:13 AM, Yang Yingliang wrote:
>
>> @@ -263,7 +264,7 @@ void tcf_hash_insert(struct tcf_common *p, struc=
t tcf_hashinfo *hinfo)
>>   }
>>   EXPORT_SYMBOL(tcf_hash_insert);
>>
>> -static struct tc_action_ops *act_base =3D NULL;
>> +static struct tc_action_ops *act_base;
>
> From a readability point of view, I think this makes it worse, also t=
he other places
> where you change globals vars like that.

Then you should probably argue for a change to checkpatch. It will make
a lot of noise about such unnecessary initialization.


Bj=C3=B8rn
