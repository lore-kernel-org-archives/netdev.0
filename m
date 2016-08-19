From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH 0/5] Add eBPF hooks for cgroups
Date: Fri, 19 Aug 2016 18:37:55 +0200
Message-ID: <20160819163755.GE29430@pox.localdomain>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <20160819091941.GA2113@salvia>
 <b2b52c47-c421-51fb-c4a1-c4f8a924f7aa@zonque.org>
 <57B6EB79.50602@iogearbox.net>
 <20160819163104.GA25216@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, htejun@fb.com, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37556 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754127AbcHSQh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 12:37:58 -0400
Received: by mail-wm0-f41.google.com with SMTP id i5so49328852wmg.0
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 09:37:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160819163104.GA25216@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/16 at 06:31pm, Pablo Neira Ayuso wrote:
> Why do you need global seccomp policies? The process knows better what
> he needs to place in his sandbox, so attaching this from the process
> itself makes more sense to me... Anyway, this reminds me to selinux.

Two different objectives. The point is to sandbox applications and
restrict their capabilities. It's not the application itself but the task
orchestration system around it that manages the policies.
