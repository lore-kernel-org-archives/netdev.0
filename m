From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 07/16] dma-debug: add debugfs interface
Date: Sun, 11 Jan 2009 00:15:31 +0100
Message-ID: <20090110231531.GN17917@elte.hu>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-8-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:38201 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778AbZAJXP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2009 18:15:57 -0500
Content-Disposition: inline
In-Reply-To: <1231517970-20288-8-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> +/* debugfs dentry's for the stuff above */
> +static struct dentry *dma_debug_dent;
> +static struct dentry *global_disable_dent;
> +static struct dentry *error_count_dent;
> +static struct dentry *show_all_errors_dent;
> +static struct dentry *show_num_errors_dent;
> +static struct dentry *num_free_entries_dent;
> +static struct dentry *min_free_entries_dent;

should all be __read_mostly.

	Ingo
