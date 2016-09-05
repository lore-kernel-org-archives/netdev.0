From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v3 3/6] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Mon, 5 Sep 2016 20:43:05 +0200
Message-ID: <450b6b76-f83b-82d4-7a02-8cc8156236ba@zonque.org>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
 <1472241532-11682-4-git-send-email-daniel@zonque.org>
 <57C4BE77.8070309@iogearbox.net>
 <9894ace9-06f7-4c41-e8fe-6047adad740e@zonque.org>
 <57CD798D.4040604@iogearbox.net>
 <7f69d0ee-df6e-0d30-7198-16a978e53068@zonque.org>
 <57CDA6C7.5060501@iogearbox.net> <57CDBA3E.10703@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me
To: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, htejun@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:59696 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933773AbcIESnJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 14:43:09 -0400
In-Reply-To: <57CDBA3E.10703@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/2016 08:32 PM, Alexei Starovoitov wrote:
> On 9/5/16 10:09 AM, Daniel Borkmann wrote:
>> On 09/05/2016 04:09 PM, Daniel Mack wrote:

>>> I really don't think it's worth sparing 8 bytes here and then do the
>>> binary compat dance after flags are added, for no real gain.
>>
>> Sure, but there's not much of a dance needed, see for example how map_flags
>> were added some time ago. So, iff there's really no foreseeable use-case in
>> sight and since we have this flexibility in place already, then I don't
>> quite
>> follow why it's needed, if there's zero pain to add it later on. I would
>> understand it of course, if it cannot be handled later on anymore.
> 
> I agree with Daniel B. Since flags are completely unused right now,
> there is no plan to use it for anything in the coming months and
> even worse they make annoying hole in the struct, let's not
> add them. We can safely do that later. CHECK_ATTR() allows us to
> do it easily. It's not like syscall where flags are must have,
> since we cannot add it later. Here it's done trivially.

Okay then. If you both agree, I won't interfere :)


Daniel
