From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] iwlwifi: mvm: only send LEDS_CMD when the FW supports it
Date: Thu, 07 Sep 2017 15:39:05 +0300
Message-ID: <877exan0nq.fsf@kamboji.qca.qualcomm.com>
References: <CA+55aFxjHSW7v4Ttu7mGPkxdGpR-WtVoxDT5qtwxUC-Dge5a5A@mail.gmail.com>
        <20170907075152.4522-1-luca@coelho.fi>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, johannes@sipsolutions.net,
        linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
        netdev@vger.kernel.org, davem@davemloft.net,
        emmanuel.grumbach@intel.com, Luca Coelho <luciano.coelho@intel.com>
To: torvalds@linux-foundation.org, Luca Coelho <luca@coelho.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170907075152.4522-1-luca@coelho.fi> (Luca Coelho's message of
        "Thu, 7 Sep 2017 10:51:52 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Luca Coelho <luca@coelho.fi> writes:

> From: Luca Coelho <luciano.coelho@intel.com>
>
> The LEDS_CMD command is only supported in some newer FW versions
> (e.g. iwlwifi-8000C-31.ucode), so we can't send it to older versions
> (such as iwlwifi-8000C-27.ucode).
>
> To fix this, check for a new bit in the FW capabilities TLV that tells
> when the command is supported.
>
> Note that the current version of -31.ucode in linux-firmware.git
> (31.532993.0) does not have this capability bit set, so the LED won't
> work, even though this version should support it.  But we will update
> this firmware soon, so it won't be a problem anymore.
>
> Fixes: 7089ae634c50 ("iwlwifi: mvm: use firmware LED command where applicable")
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Luca Coelho <luciano.coelho@intel.com>

Linus, do you want to apply this directly or should we take it via the
normal route (wireless-drivers -> net)? If your prefer the latter when
I'm planning to submit this to Dave in a day or two and expecting it to
get to your tree in about a week, depending of course what is Dave's
schedule.

-- 
Kalle Valo
