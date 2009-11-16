From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 2/2] act_mirred: optimization
Date: Mon, 16 Nov 2009 13:27:14 +0000
Message-ID: <20091116132714.GA15056@ff.dom.local>
References: <412e6f7f0911160505x10da9a92j694669db9d030da1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:42180 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbZKPN1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 08:27:14 -0500
Received: by bwz27 with SMTP id 27so5636294bwz.21
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 05:27:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <412e6f7f0911160505x10da9a92j694669db9d030da1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-2009 14:05, Changli Gao wrote:
> On Mon, Nov 16, 2009 at 6:58 PM, David Miller <davem@davemloft.net> w=
rote:
>> From: David Miller <davem@davemloft.net>
>> Date: Mon, 16 Nov 2009 02:48:39 -0800 (PST)
>>
>>> From: Changli Gao <xiaosuo@gmail.com>
>>> Date: Mon, 16 Nov 2009 17:53:29 +0800
>>>
>>>> act_mirred: optimization.
>>>>
>>>> move checking if eaction is valid in tcf_mirred_init()
>>>>
>>>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>>>> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
>>> Also applied, thank you.
>> Nevermind, you're NOT TESTING the patches you are posting:
>>
>> net/sched/act_mirred.c: In function =E2??tcf_mirred=E2??:
>> net/sched/act_mirred.c:168: error: label =E2??out=E2?? used but not =
defined
>> net/sched/act_mirred.c:158: warning: unused variable =E2??err=E2??
>> net/sched/act_mirred.c:158: warning: unused variable =E2??retval=E2?=
?
>> make[2]: *** [net/sched/act_mirred.o] Error 1
>> make[1]: *** [net/sched] Error 2
>> make[1]: *** Waiting for unfinished jobs....
>>
>> I'm thus reverting both changes.
>>
>> Don't submit changes which are untested, it wastes my time.
>>
>=20
> I am sorry about that. But I did test it before submitting these two,
> and I am just wondering if they are applied without any error. Would
> you post the file after being patched? I think it will be helpful to
> finger out the real problem.
>=20
> BTW: since my email client thunderbird was broken, I used google
> webmail(with ViewSourceWith addon) to submit these two patches.
>=20

It seems PATCH 1/2 might be broken by email (but I got it second hand
from gmail). checkpatch output:

ERROR: patch seems to be corrupt (line wrapped?)
#17: FILE: net/sched/act_mirred.c:147:
struct tc_action *a,

WARNING: printk() should include KERN_ facility level
#34: FILE: net/sched/act_mirred.c:160:
+                       printk("tcf_mirred unknown action %d\n",

total: 1 errors, 1 warnings, 89 lines checked

mirred1.diff has style problems, please review.  If any of these errors
are false positives report them to the maintainer, see
CHECKPATCH in MAINTAINERS.

Jarek P.
