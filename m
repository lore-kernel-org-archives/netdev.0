From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 07/16] dma-debug: add debugfs interface
Date: Sun, 11 Jan 2009 00:08:26 +0100
Message-ID: <20090110230826.GJ17917@elte.hu>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-8-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:52086 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778AbZAJXIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2009 18:08:42 -0500
Content-Disposition: inline
In-Reply-To: <1231517970-20288-8-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> +/* Global error count */
> +static u32 error_count;
> +
> +/* Global error show enable*/
> +static u32 show_all_errors __read_mostly;
> +/* Number of errors to show */
> +static u32 show_num_errors = 1;
> +
>  static u32 num_free_entries;
>  static u32 min_free_entries;

Small detail: please use native C types for non-hardware variables - 
'unsigned int', 'unsigned long', etc.

u32/u64 is typically used for variables where there is a real significance 
to the precise width of the variable: there's either a hardware or a 
user-space ABI involved.

	Ingo
