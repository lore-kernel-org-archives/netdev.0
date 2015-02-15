From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 0/6] bpf: Enable BPF JIT on ppc32
Date: Sun, 15 Feb 2015 21:09:19 +0100
Message-ID: <54E0FCEF.6090701@iogearbox.net>
References: <1424023605-2416-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	benh@kernel.crashing.org, mpe@ellerman.id.au, ast@kernel.org
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47857 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932265AbbBOUJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 15:09:35 -0500
In-Reply-To: <1424023605-2416-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/15/2015 07:06 PM, Denis Kirjanov wrote:
> This patch series enables BPF JIT on ppc32. There are relatevily
> few chnages in the code to make it work.
>
> All test_bpf tests passed both on 7447a and P2041-based machines.

I'm just wondering, next to the feedback that has already been
provided, would opening this up for ppc32 make it significantly
more difficult in future to migrate from classic BPF JIT to eBPF
JIT eventually (which is what we want long-term)? Being curious,
is there any ongoing effort from ppc people?
