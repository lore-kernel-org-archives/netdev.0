From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [1/2] mwifiex: fix the length parameter of a memset
Date: Sat,  3 Sep 2016 10:04:41 +0000 (UTC)
Message-ID: <20160903100441.E591B6201F@smtp.codeaurora.org>
References: <1470641928-26616-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akarwar@marvell.com, nishants@marvell.com,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: Christophe Jaillet <christophe.jaillet@wanadoo.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470641928-26616-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christophe Jaillet <christophe.jaillet@wanadoo.fr> wrote:
> In 'mwifiex_get_ver_ext', we have:
>    struct mwifiex_ver_ext ver_ext;
> 
>    memset(&ver_ext, 0, sizeof(struct host_cmd_ds_version_ext));
> 
> This is likely that memset'ing sizeof(struct mwifiex_ver_ext) was expected.
> Remove the ambiguity by using the variable name directly instead of its
> type.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Thanks, 2 patches applied to wireless-drivers-next.git:

ba852018d493 mwifiex: fix the length parameter of a memset
6a1622000ac9 mwifiex: simplify length computation for some memset

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9266889/
