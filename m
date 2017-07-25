From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 master v2 0/2] Minor BPF updates
Date: Tue, 25 Jul 2017 11:48:16 -0700
Message-ID: <20170725114816.2c61df50@xeon-e3>
References: <1500765739-10681-1-git-send-email-daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35492 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750783AbdGYSsX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 14:48:23 -0400
Received: by mail-pf0-f182.google.com with SMTP id h29so26561630pfd.2
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 11:48:23 -0700 (PDT)
In-Reply-To: <1500765739-10681-1-git-send-email-daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Jul 2017 01:22:17 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Two minor updates to the BPF code, first one makes use of the
> recently exposed owner_jited in fdinfo to report whether a
> load issue related to tail calls occured, and second one fixes
> up custom mount of bpf fs when passed via env.
> 
> Thanks!
> 
> v1 -> v2:
>   - Moved bpf_derive_prog_from_fdinfo() under HAVE_ELF.
>   - Rest as is.
> 
> Daniel Borkmann (2):
>   bpf: improve error reporting around tail calls
>   bpf: fix mnt path when from env
> 
>  lib/bpf.c | 281 +++++++++++++++++++++++++++++++++++++++++++++++---------------
>  1 file changed, 214 insertions(+), 67 deletions(-)
> 

Applied to master
