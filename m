From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] samples: bpf: enable trace samples for s390x
Date: Mon, 06 Jul 2015 12:28:03 -0700
Message-ID: <559AD6C3.20803@plumgrid.com>
References: <20150706162007.69824718@holzheu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	netdev@vger.kernel.org
To: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:34996 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755027AbbGFT2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 15:28:06 -0400
Received: by pdbci14 with SMTP id ci14so110931023pdb.2
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 12:28:06 -0700 (PDT)
In-Reply-To: <20150706162007.69824718@holzheu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/6/15 7:20 AM, Michael Holzheu wrote:
> The trace bpf samples do not compile on s390x because they use x86
> specific fields from the "pt_regs" structure.
>
> Fix this and access the fields via new PT_REGS macros.
>
> Signed-off-by: Michael Holzheu<holzheu@linux.vnet.ibm.com>
> ---
>   samples/bpf/bpf_helpers.h  | 25 +++++++++++++++++++++++++
>   samples/bpf/tracex1_kern.c |  2 +-
>   samples/bpf/tracex2_kern.c |  6 +++---
>   samples/bpf/tracex3_kern.c |  4 ++--
>   samples/bpf/tracex4_kern.c |  6 +++---
>   samples/bpf/tracex5_kern.c |  6 +++---
>   6 files changed, 37 insertions(+), 12 deletions(-)

Looks good. Thanks!
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
