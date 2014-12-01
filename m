From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] mips: bpf: Fix broken BPF_MOD
Date: Mon, 01 Dec 2014 16:50:56 +0300
Message-ID: <547C7240.4010401@cogentembedded.com>
References: <1417427822-12729-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: markos.chandras@imgtec.com
To: Denis Kirjanov <kda@linux-powerpc.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:32842 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932079AbaLANvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 08:51:00 -0500
Received: by mail-la0-f44.google.com with SMTP id ge10so8850147lab.3
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 05:50:58 -0800 (PST)
In-Reply-To: <1417427822-12729-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/1/2014 12:57 PM, Denis Kirjanov wrote:

    You should CC the 'linux-mips' ML.

> Remove optimize_div() from BPF_MOD | BPF_K case
> since we don't know the dividend and fix the
> emit_mod() by reading the mod operation result from HI register

    Isn't this 2 unrelated fixes? They should be in 2 patches, not a single 
one in that case.

> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> ---
>   arch/mips/net/bpf_jit.c |    4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)

WBR, Sergei
