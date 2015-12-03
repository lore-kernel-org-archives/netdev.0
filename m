From: Jason Baron <jbaron@akamai.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Thu, 3 Dec 2015 15:10:15 -0500
Message-ID: <5660A1A7.3080301@akamai.com>
References: <CACT4Y+ZnWRZfQC25uW=GXHAJB=GX0L6tJQUy43P6WNR3=hwT8Q@mail.gmail.com>
 <20151203130525.GB4164@mrl.redhat.com>
 <CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
 <CANn89iKEv-q6EFi1eX+Hk_2+jNfZ0ayUqUn_Fh1U7RTs9xjdXg@mail.gmail.com>
 <CACT4Y+bgeqS05zqkAHkxzAP7fuvFSkeEybwDTizw6Gp8KK28Fw@mail.gmail.com>
 <CANn89i+d=mTJ-hAhhgPXsZPGAkQdECxRdbkeRLfozRq8i9Ms+g@mail.gmail.com>
 <CACT4Y+YJe-OJj9q1Kr5-_ApDt1UBKLjTRxhP62EHtEAwZt5vXw@mail.gmail.com>
 <f7twpsvgyar.fsf@aconole.bos.csb> <566098BD.6010803@akamai.com>
 <1449172984.12092.0.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Joe Perches <joe@perches.com>, Aaron Conole <aconole@redhat.com>,
	Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:43561 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753387AbbLCUKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 15:10:16 -0500
In-Reply-To: <1449172984.12092.0.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/03/2015 03:03 PM, Joe Perches wrote:
> On Thu, 2015-12-03 at 14:32 -0500, Jason Baron wrote:
>> On 12/03/2015 01:52 PM, Aaron Conole wrote:
>>> I think that as a minimum, the following patch should be evaluted,
>>> but am unsure to whom I should submit it (after I test):
> []
>> Agreed - the intention here is certainly to have no side effects. It
>> looks like 'no_printk()' is used in quite a few other places that would
>> benefit from this change. So we probably want a generic
>> 'really_no_printk()' macro.
> 
> https://lkml.org/lkml/2012/6/17/231
> 

I don't see this in the tree. Also maybe we should just convert
no_printk() to do what your 'eliminated_printk()'. So we can convert all
users with this change?

Thanks,

-Jason
