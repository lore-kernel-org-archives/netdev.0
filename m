From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] mwifiex: fix unconditional error return in .add_virtual_intf callback
Date: Tue, 05 Jul 2016 16:09:26 +0300
Message-ID: <87twg42pvd.fsf@kamboji.qca.qualcomm.com>
References: <1467401982-18943-1-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Amitkumar Karwar <akarwar@marvell.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Nishant Sarmukadam <nishants@marvell.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467401982-18943-1-git-send-email-javier@osg.samsung.com>
	(Javier Martinez Canillas's message of "Fri, 1 Jul 2016 15:39:42
	-0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Javier Martinez Canillas <javier@osg.samsung.com> writes:

> The commit 7311ea850079 ("mwifiex: fix AP start problem for newly added
> interface") attempted to fix an issue when a new AP interface is added.
>
> But the patch didn't check the return value of the functions doing the
> firmware calls and returned an error even if the functions didn't fail.
>
> This prevents the network device to be registered properly, so fix it.
>
> Fixes: commit 7311ea850079 ("mwifiex: fix AP start problem for newly added interface")
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

The fixes line should be:

Fixes: 7311ea850079 ("mwifiex: fix AP start problem for newly added interface")

I can fix that before I apply the patch.

-- 
Kalle Valo
