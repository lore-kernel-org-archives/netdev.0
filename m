From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: fix unconditional error return in .add_virtual_intf
 callback
Date: Tue,  5 Jul 2016 13:28:19 +0000 (UTC)
Message-ID: <20160705132819.6B3C9611CF@smtp.codeaurora.org>
References: <1467401982-18943-1-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Javier Martinez Canillas <javier@osg.samsung.com>,
	Amitkumar Karwar <akarwar@marvell.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Nishant Sarmukadam <nishants@marvell.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467401982-18943-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Javier Martinez Canillas <javier@osg.samsung.com> wrote:
> The commit 7311ea850079 ("mwifiex: fix AP start problem for newly added
> interface") attempted to fix an issue when a new AP interface is added.
> 
> But the patch didn't check the return value of the functions doing the
> firmware calls and returned an error even if the functions didn't fail.
> 
> This prevents the network device to be registered properly, so fix it.
> 
> Fixes: 7311ea850079 ("mwifiex: fix AP start problem for newly added interface")
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

f152bdad6208 mwifiex: fix unconditional error return in .add_virtual_intf callback

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9210355/
