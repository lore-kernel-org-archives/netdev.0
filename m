From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] act_police: fix a crash during removal
Date: Sun, 5 Jun 2016 22:41:29 -0700
Message-ID: <CAM_iQpV9e7RcKpw7EE-36uq1NMjVYrWRXSSMr7NNHrQ=gw3tkw@mail.gmail.com>
References: <1464822920-14205-1-git-send-email-xiyou.wangcong@gmail.com>
 <1464822920-14205-6-git-send-email-xiyou.wangcong@gmail.com> <20160603.192841.407832783155363455.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?UTF-8?B?0KHRgtCw0YEg0J3QuNGH0LjQv9C+0YDQvtCy0LjRhw==?=
	<stasn77@gmail.com>, Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:36774 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbcFFFlt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 01:41:49 -0400
Received: by mail-yw0-f182.google.com with SMTP id x189so131073543ywe.3
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 22:41:49 -0700 (PDT)
In-Reply-To: <20160603.192841.407832783155363455.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 3, 2016 at 4:28 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Wed,  1 Jun 2016 16:15:20 -0700
>
>> The police action is using its own code to initialize tcf hash
>> info, which makes us to forgot to initialize a->hinfo correctly.
>> Fix this by calling the helper function tcf_hash_create() directly.
>>
>> This patch fixed the following crash:
>  ...
>> Fixes: ddf97ccdd7cb ("net_sched: add network namespace support for t=
c actions")
>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> This adds a new warning, please resubmit with this fixed.
>
> net/sched/act_police.c: In function =E2=80=98tcf_act_police_locate=E2=
=80=99:
> net/sched/act_police.c:247:3: warning: =E2=80=98police=E2=80=99 may b=
e used uninitialized in this function [-Wmaybe-uninitialized]

Oh, sure, my compiler didn't catch this.

I will send v2 tomorrow.
