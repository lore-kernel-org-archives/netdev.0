From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 2/2] rtl8xxxu: Fix for bogus data used to determine
 macpower
Date: Wed, 2 Nov 2016 20:00:03 -0500
Message-ID: <10e32bb4-fe16-6a0f-eaf4-1142c23e7b56@lwfinger.net>
References: <cover.1477769750.git.john@zgus.com> <20161030102112.GA5789@cube>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: John Heenan <john@zgus.com>,
        Jes Sorensen <Jes.Sorensen@redhat.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161030102112.GA5789@cube>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/30/2016 05:21 AM, John Heenan wrote:
> Code tests show data returned by rtl8xxxu_read8(priv, REG_CR), used to set
> macpower, is never 0xea. It is only ever 0x01 (first time after modprobe)
> using wpa_supplicant and 0x00 thereafter using wpa_supplicant. These results
> occurs with 'Fix for authentication failure' [PATCH 1/2] in place.
>
> Whatever was returned, code tests always showed that at least
> rtl8xxxu_init_queue_reserved_page(priv);
> is always required. Not called if macpower set to true.
>
> Please see cover letter, [PATCH 0/2], for more information from tests.

That cover letter will NOT be included in the commit message, thus referring to 
it here is totally pointless.

>
> For rtl8xxxu-devel branch of git.kernel.org/pub/scm/linux/kernel/git/jes/linux.git

Same comment as for the previous patch.

Again I leave the review of the code changes to Jes.

Larry
