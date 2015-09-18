From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net-next 1/2] cls_bpf: introduce integrated actions
Date: Fri, 18 Sep 2015 08:13:44 -0400
Message-ID: <55FBFFF8.3050101@mojatatu.com>
References: <1442383543-4720-1-git-send-email-ast@plumgrid.com>
 <1442383543-4720-2-git-send-email-ast@plumgrid.com>
 <55FAB40E.304@mojatatu.com> <55FABC7B.6060502@iogearbox.net>
 <55FAD9F4.1010603@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35538 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425AbbIRMNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 08:13:47 -0400
Received: by igbkq10 with SMTP id kq10so16420717igb.0
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 05:13:46 -0700 (PDT)
In-Reply-To: <55FAD9F4.1010603@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/17/15 11:19, Alexei Starovoitov wrote:

> misread as bpf program now executes the actions and bypasses
> tcf_exts_exec() ? Well, that may be interesting idea for
> the future,

And above is precisely why i raised the concern. You are already
bypassing tcf_exts_exec with that patch. It is a big jump.
It is kind of hard to continue the discussion because i notice
Dave just took in the patches.

Please dont go the above path of fully fledged bypass.
The architecture is about small tools that come together to
provide complex processing. ebpf may be the best classifier
today - but by no means the only one or guaranteed that nothing
better will exist for speficic use cases.
If there is something in the core that needs improvement
for the benefit of all, then lets do that. Example i find
the classid metadata interesting but flinching at ACT_REDIRECT.

cheers,
jamal
