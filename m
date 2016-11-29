From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4 3/3] samples: bpf: add userspace example for
 modifying sk_bound_dev_if
Date: Tue, 29 Nov 2016 08:52:31 -0700
Message-ID: <715f445a-c667-9f02-a236-8a95a69b5d69@cumulusnetworks.com>
References: <1480394329-24847-1-git-send-email-dsa@cumulusnetworks.com>
 <1480394329-24847-4-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33169 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934086AbcK2Pwe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 10:52:34 -0500
Received: by mail-pg0-f46.google.com with SMTP id 3so70853716pgd.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 07:52:33 -0800 (PST)
In-Reply-To: <1480394329-24847-4-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/16 9:38 PM, David Ahern wrote:
> +	ret = bpf_prog_detach(cg_fd, BPF_CGROUP_INET_SOCK);
> +	ret = bpf_prog_attach(prog_fd, cg_fd, BPF_CGROUP_INET_SOCK);

forgot to update this to BPF_CGROUP_INET_SOCK_CREATE.

will send v5
