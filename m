From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [8/10] ath9k: Use ARRAY_SIZE macro
Date: Mon, 25 Sep 2017 09:15:21 +0200
Message-ID: <27be6ac3227f4738abf6ebea6410c365@euamsexm01a.eu.qualcomm.com>
References: <1504439110050-1887263060-8-diffsplit-thomas@m3y3r.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <kvalo@codeaurora.org>, <linux-wireless@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Thomas Meyer <thomas@m3y3r.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504439110050-1887263060-8-diffsplit-thomas@m3y3r.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Meyer <thomas@m3y3r.de> wrote:

> Use ARRAY_SIZE macro, rather than explicitly coding some variant of it
> yourself.
> Found with: find -type f -name "*.c" -o -name "*.h" | xargs perl -p -i -e
> 's/\bsizeof\s*\(\s*(\w+)\s*\)\s*\ /\s*sizeof\s*\(\s*\1\s*\[\s*0\s*\]\s*\)
> /ARRAY_SIZE(\1)/g' and manual check/verification.
> 
> Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
> Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>

Patch applied to ath-next branch of ath.git, thanks.

896cbefadf62 ath9k: Use ARRAY_SIZE macro

-- 
https://patchwork.kernel.org/patch/9936271/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
