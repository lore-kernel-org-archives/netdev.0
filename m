From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH] mwifiex: fix unconditional error return in
 .add_virtual_intf callback
Date: Mon, 4 Jul 2016 10:18:52 +1000
Message-ID: <CAGRGNgUdUf2TC1ix-uZNR+kuNApLXduAivMY=3AmgXKDx-cxyg@mail.gmail.com>
References: <1467401982-18943-1-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Nishant Sarmukadam <nishants@marvell.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:34624 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932182AbcGDATN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2016 20:19:13 -0400
In-Reply-To: <1467401982-18943-1-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

On Sat, Jul 2, 2016 at 5:39 AM, Javier Martinez Canillas
<javier@osg.samsung.com> wrote:
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

Looks correct to me as Dan Carpenter submitted the same fix.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
