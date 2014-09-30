From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] hostap: proc: Remove unused variable
Date: Tue, 30 Sep 2014 12:56:26 -0400
Message-ID: <20140930165626.GD11919@tuxdriver.com>
References: <1410909415-11661-1-git-send-email-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <j@w1.fi>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linaro-kernel@lists.linaro.org
To: Mark Brown <broonie@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59483 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753290AbaI3RAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 13:00:12 -0400
Content-Disposition: inline
In-Reply-To: <1410909415-11661-1-git-send-email-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2014 at 04:16:55PM -0700, Mark Brown wrote:
> Since "hostap: proc: substitute loops by %*phN" (62c5afb8e388) the
> variable i has been unused in prism2_bss_list_proc_show() so remove it.
> 
> Signed-off-by: Mark Brown <broonie@kernel.org>
> ---
>  drivers/net/wireless/hostap/hostap_proc.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/hostap/hostap_proc.c b/drivers/net/wireless/hostap/hostap_proc.c
> index 3a23a6d..dd84557 100644
> --- a/drivers/net/wireless/hostap/hostap_proc.c
> +++ b/drivers/net/wireless/hostap/hostap_proc.c
> @@ -168,7 +168,6 @@ static int prism2_bss_list_proc_show(struct seq_file *m, void *v)
>  	local_info_t *local = m->private;
>  	struct list_head *ptr = v;
>  	struct hostap_bss_info *bss;
> -	int i;
>  
>  	if (ptr == &local->bss_list) {
>  		seq_printf(m, "#BSSID\tlast_update\tcount\tcapab_info\tSSID(txt)\t"
> -- 
> 2.1.0

What tree are you using?  In wireless-next, I still see a loop in
that function using i as an index variable.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
