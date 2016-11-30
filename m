From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 2/3] bpf: Add new cgroup attach type to enable
 sock modifications
Date: Tue, 29 Nov 2016 17:43:08 -0700
Message-ID: <781e66b2-007c-bd56-2cd1-543c1f5dcdb7@cumulusnetworks.com>
References: <1480434813-3141-1-git-send-email-dsa@cumulusnetworks.com>
 <1480434813-3141-3-git-send-email-dsa@cumulusnetworks.com>
 <20161129200141.GB24152@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35455 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752250AbcK3AnK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 19:43:10 -0500
Received: by mail-pf0-f180.google.com with SMTP id i88so34896113pfk.2
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 16:43:10 -0800 (PST)
In-Reply-To: <20161129200141.GB24152@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/16 1:01 PM, Alexei Starovoitov wrote:
> Could you also expose sk_protcol and sk_type as read only fields?

Those are bitfields in struct sock, so can't use offsetof or sizeof. Any existing use cases that try to load a bitfield in a bpf that I can look at?
