From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 5/6] cxgb4: Add main driver file and driver Makefile
Date: Tue, 30 Mar 2010 14:19:04 -0700
Message-ID: <20100330141904.5236fe44@nehalam>
References: <1269975142-30896-1-git-send-email-dm@chelsio.com>
	<1269975142-30896-2-git-send-email-dm@chelsio.com>
	<1269975142-30896-3-git-send-email-dm@chelsio.com>
	<1269975142-30896-4-git-send-email-dm@chelsio.com>
	<1269975142-30896-5-git-send-email-dm@chelsio.com>
	<1269975142-30896-6-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44580 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754868Ab0C3VTY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 17:19:24 -0400
In-Reply-To: <1269975142-30896-6-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Mar 2010 10:52:21 -0800
Dimitris Michailidis <dm@chelsio.com> wrote:

> +static struct cxgb4_proc_entry proc_files[] = {
> +#ifdef CONFIG_PROC_FS
> +	{ "l2t", 0444, ADAP_NEED_L2T, 0, &t4_l2t_proc_fops },
> +#endif
> +	{ "lb_stats", 0444, 0, 0, &lb_stats_proc_fops },
> +	{ "path_mtus", 0644, 0, 0, &mtutab_proc_fops },
> +	{ "qstats", 0444, 0, 0, &sge_stats_proc_fops },
> +	{ "rss", 0444, 0, 0, &rss_proc_fops },
> +	{ "tcp_stats", 0444, 0, 0, &tcp_stats_proc_fops },
> +	{ "tids", 0444, ADAP_NEED_OFLD, 0, &tid_info_proc_fops },
> +	{ "tp_err_stats", 0444, 0, 0, &tp_err_stats_proc_fops },
> +	{ "trace0", 0644, 0, 0, &mps_trc_proc_fops },
> +	{ "trace1", 0644, 0, 1, &mps_trc_proc_fops },
> +	{ "trace2", 0644, 0, 2, &mps_trc_proc_fops },
> +	{ "trace3", 0644, 0, 3, &mps_trc_proc_fops },
> +	{ "uld", 0444, 0, 0, &uld_proc_fops },
> +};
> +

Do you really need this large number of /proc files.
It creates another stable API to worry about.  If it is just for
debugging move it to debugfs, or better yet just drop it.

-- 
