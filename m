From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] staging: adm8211: fix checkpatch error for trailing statements on next line
Date: Mon, 04 May 2015 15:42:04 +0300
Message-ID: <87lhh4wm3n.fsf@kamboji.qca.qualcomm.com>
References: <20150503104231.GA3607@bytefire-computer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Okash Khawaja <okash.khawaja@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150503104231.GA3607@bytefire-computer> (Okash Khawaja's
	message of "Sun, 3 May 2015 11:42:31 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Okash Khawaja <okash.khawaja@gmail.com> writes:

> This patch fixes the checkpatch.pl error:
>
> ERROR: trailing statements should be on next line
>
> More specifically, the fix has been applied to the four occurances of the error listed below.
>
> ERROR: trailing statements should be on next line
> #1101: FILE: drivers/net/wireless/adm8211.c:1101:
> +               case  0x8: reg |= (0x1 << 14);
>
> ERROR: trailing statements should be on next line
> #1103: FILE: drivers/net/wireless/adm8211.c:1103:
> +               case 0x16: reg |= (0x2 << 14);
>
> ERROR: trailing statements should be on next line
> #1105: FILE: drivers/net/wireless/adm8211.c:1105:
> +               case 0x32: reg |= (0x3 << 14);
>
> ERROR: trailing statements should be on next line
> #1107: FILE: drivers/net/wireless/adm8211.c:1107:
> +                 default: reg |= (0x0 << 14);
>
> Signed-off-by: Okash Khawaja <okash.khawaja@gmail.com>
> ---
>  drivers/net/wireless/adm8211.c | 20 ++++++++++++--------
>  1 file changed, 12 insertions(+), 8 deletions(-)

The patch has incorrectly "staging:" prefix in the title, please fix
that. "adm8211:" is enough, you don't need anything for drivers in
drivers/net/wireless.

-- 
Kalle Valo
