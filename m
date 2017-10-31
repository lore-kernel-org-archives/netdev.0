From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 2/3] tools: bpftool: show filenames of pinned
 objects
Date: Tue, 31 Oct 2017 10:35:40 -0700
Message-ID: <20171031103540.52d7c163@cakuba.netronome.com>
References: <20171031073632.8140-1-bhole_prashant_q7@lab.ntt.co.jp>
        <20171031073632.8140-3-bhole_prashant_q7@lab.ntt.co.jp>
        <40cac52c-36a5-f83f-22d4-2ac2bd90cc34@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Quentin Monnet <quentin.monnet@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:54007 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753703AbdJaRfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 13:35:44 -0400
Received: by mail-qt0-f180.google.com with SMTP id n61so21727070qte.10
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 10:35:44 -0700 (PDT)
In-Reply-To: <40cac52c-36a5-f83f-22d4-2ac2bd90cc34@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Oct 2017 11:41:34 +0000, Quentin Monnet wrote:
> > +{
> > +	char *path[] = {"/sys/fs/bpf/", NULL};  
> 
> This will not work for progs/maps pinned elsewhere on the system. Might
> be worth mentioning in the documentation?

Or should the code just scan all the mount points to find the bpffs
ones?
