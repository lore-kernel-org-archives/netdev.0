From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCHv4 wl-drv-next 2/2] mt7601u: use linux/bitfield.h
Date: Tue, 05 Jul 2016 16:16:20 +0300
Message-ID: <87poqs2pjv.fsf@kamboji.qca.qualcomm.com>
References: <1467718979-20029-1-git-send-email-jakub.kicinski@netronome.com>
	<1467718979-20029-3-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	hannes@stressinduktion.org, nbd@nbd.name,
	linux-kernel@vger.kernel.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467718979-20029-3-git-send-email-jakub.kicinski@netronome.com>
	(Jakub Kicinski's message of "Tue, 5 Jul 2016 12:42:59 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jakub Kicinski <jakub.kicinski@netronome.com> writes:

> Use the newly added linux/bitfield.h.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

[...]

> +#define MT76_SET	FIELD_PUT
> +#define MT76_GET	FIELD_GET

This define is useless now, I would just remove it entirely. But you can
do that in a follow up patch.

-- 
Kalle Valo
