From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v4 net] bpf: add bpf_sk_netns_id() helper
Date: Wed, 15 Feb 2017 19:16:03 -0700
Message-ID: <cc15d1fa-dd38-c01b-7a42-9eaf206d98a2@cumulusnetworks.com>
References: <1486432968-3255218-1-git-send-email-ast@fb.com>
 <87h93xqlui.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33190 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751732AbdBPCQG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 21:16:06 -0500
Received: by mail-pf0-f172.google.com with SMTP id c73so1449441pfb.0
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 18:16:06 -0800 (PST)
In-Reply-To: <87h93xqlui.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/14/17 12:21 AM, Eric W. Biederman wrote:
>> in cases where bpf programs are looking at sockets and packets
>> that belong to different netns, it could be useful to get an id
>> that uniquely identify a netns within the whole system.
> It could be useful but there is no unique namespace id.
> 

Have you given thought to a unique namespace id? Networking tracepoints
for example could really benefit from a unique id.
