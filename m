From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 2/3] bpf: Add new cgroup attach type to enable
 sock modifications
Date: Wed, 30 Nov 2016 09:24:08 -0700
Message-ID: <55a09e09-5c16-3d4a-7457-ae3baa2c5cb8@cumulusnetworks.com>
References: <1480434813-3141-1-git-send-email-dsa@cumulusnetworks.com>
 <1480434813-3141-3-git-send-email-dsa@cumulusnetworks.com>
 <20161129200141.GB24152@ast-mbp.thefacebook.com>
 <781e66b2-007c-bd56-2cd1-543c1f5dcdb7@cumulusnetworks.com>
 <20161130005906.GB29591@ast-mbp.thefacebook.com>
 <d3359d0c-8995-d605-cd2d-f0558fdd0408@cumulusnetworks.com>
 <20161130054154.GC31581@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33826 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932582AbcK3QYI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 11:24:08 -0500
Received: by mail-pf0-f173.google.com with SMTP id c4so39949967pfb.1
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 08:24:07 -0800 (PST)
In-Reply-To: <20161130054154.GC31581@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/16 10:41 PM, Alexei Starovoitov wrote:
> I don't see a complexity. It was straightforward for skb bitfields,
> but if there is some unforeseen issue, it's better to tackle it now
> otherwise the feature may never come and this 'infra for sockets' will
> stay as 'infra for vrf only' and I'm struggling to convince myself that it's ok.
> So I'll try to tweak this patch to add these 3 fields...
> 

regardless of whether the change is attached to this patch set or sent as a follow on, I will make 2 separate patches -- 1 that adds the fields to bpf_sock and updates the filter.c code and a second patch that adds a test case and automation for it. There is no reason to combine it into 1 large patch.

If you think the use case to fail socket create based on family/proto/type checks is valid, it is valid regardless of when the patch comes.

I take your comment to mean you believe if I don't do it now then it won't get done. Am I over reading your comment? Do you really believe it?
