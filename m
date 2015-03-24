From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc: m_bpf: fix next arg selection after tc
 opcode
Date: Tue, 24 Mar 2015 15:46:23 -0700
Message-ID: <20150324154623.07cfe557@urahara>
References: <1af5314868a14e738b049319dc2c21102134bc9b.1426669396.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33346 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898AbbCXWqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:46:21 -0400
Received: by pabxg6 with SMTP id xg6so7663733pab.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:46:20 -0700 (PDT)
In-Reply-To: <1af5314868a14e738b049319dc2c21102134bc9b.1426669396.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Mar 2015 10:13:34 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Next argument after the tc opcode/verdict is optional, using NEXT_ARG()
> requires to have another argument after that one otherwise tc will bail
> out. Therefore, we need to advance to the next argument manually as done
> elsewhere.
> 
> Fixes: 86ab59a6660f ("tc: add support for BPF based actions")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied (to master).
