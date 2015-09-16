From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/2] bpf: add bpf_redirect() helper
Date: Tue, 15 Sep 2015 21:11:39 -0700
Message-ID: <55F8EBFB.2080009@plumgrid.com>
References: <1442368295-5204-1-git-send-email-ast@plumgrid.com>
 <1442368295-5204-3-git-send-email-ast@plumgrid.com>
 <55F8DD89.5090709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33893 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112AbbIPELl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 00:11:41 -0400
Received: by padhy16 with SMTP id hy16so196319504pad.1
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 21:11:41 -0700 (PDT)
In-Reply-To: <55F8DD89.5090709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/15/15 8:10 PM, John Fastabend wrote:
> Nice, I like this. But just to be sure I read this correctly this will
> only work on the ingress qdisc for now right? To get the tx side working
> will require a bit more care.

correct.
For egress I'm waiting for Daniel to resubmit his preclassifier patch
and I'll hook this skb_do_redirect() there as well.
Other options are also possible, but preclassifier looks the best for
this purpose, since it's lockless.
