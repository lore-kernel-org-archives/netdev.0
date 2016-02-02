From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute2] tc: fix compilation with old gcc (< 4.6) (bis)
Date: Tue, 2 Feb 2016 15:51:57 +1100
Message-ID: <20160202155157.2f492bfd@samsung9>
References: <1f5ba49033cd4c55a0d0005487efde39@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"julien.floret@6wind.com" <julien.floret@6wind.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:46497 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752127AbcBBEwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 23:52:22 -0500
In-Reply-To: <1f5ba49033cd4c55a0d0005487efde39@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Jan 2016 11:01:45 +0000
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
> index 42c8841869f5..219ffa582c1a 100644
> --- a/tc/tc_bpf.c
> +++ b/tc/tc_bpf.c
> @@ -49,6 +49,10 @@
>  #include "tc_util.h"
>  #include "tc_bpf.h"
>  
> +#ifndef AF_ALG
> +#define AF_ALG 38
> +#endif

Why is this here? AF_ALG is not used anywhere in this code.

Please remove it and resubmit
