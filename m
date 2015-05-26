From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2,
 1/2] adm8211: fix checkpatch errors for indentation and new line
Date: Tue, 26 May 2015 10:48:02 +0000 (UTC)
Message-ID: <20150526104802.E5F631416A0@smtp.codeaurora.org>
References: <20150511115325.GA5092@bytefire-computer>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Okash Khawaja <okash.khawaja@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150511115325.GA5092@bytefire-computer>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> This patch fixes these checkpatch.pl errors around a single switch-case
> block:
> 
> ERROR: switch and case should be at the same indent
> ERROR: trailing statements should be on next line
> 
> More specifically, the fix has been applied to the five occurances of
> the errors listed below.
> 
> ERROR: switch and case should be at the same indent
> #1100: FILE: adm8211.c:1100:
> +               switch (cline) {
> [...]
> +                 default: reg |= (0x0 << 14);
> 
> ERROR: trailing statements should be on next line
> #1101: FILE: adm8211.c:1101:
> +               case  0x8: reg |= (0x1 << 14);
> 
> ERROR: trailing statements should be on next line
> #1103: FILE: adm8211.c:1103:
> +               case 0x16: reg |= (0x2 << 14);
> 
> ERROR: trailing statements should be on next line
> #1105: FILE: adm8211.c:1105:
> +               case 0x32: reg |= (0x3 << 14);
> 
> ERROR: trailing statements should be on next line
> #1107: FILE: adm8211.c:1107:
> +                 default: reg |= (0x0 << 14);
> 
> 
> Signed-off-by: Okash Khawaja <okash.khawaja@gmail.com>

Thanks, 2 patches applied to wireless-drivers-next.git:

f5c65f38912e adm8211: fix checkpatch errors for indentation and new line
fe0a483ecf44 adm8211: fixed the possible pci cache line sizes inside switch-case

Kalle Valo
