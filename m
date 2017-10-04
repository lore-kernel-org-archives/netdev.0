From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] nfp: convert nfp_eth_set_bit_config() into a macro
Date: Wed, 04 Oct 2017 10:44:30 -0700 (PDT)
Message-ID: <20171004.104430.371058999122748879.davem@davemloft.net>
References: <20171003200546.165731-1-mka@chromium.org>
        <20171003145000.53683e21@cakuba>
        <20171004174215.GM173745@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, simon.horman@netronome.com,
        dirk.vandermerwe@netronome.com, oss-drivers@netronome.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        renato.golin@linaro.org, manojgupta@chromium.org,
        groeck@chromium.org, dianders@chromium.org
To: mka@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171004174215.GM173745@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthias Kaehlcke <mka@chromium.org>
Date: Wed, 4 Oct 2017 10:42:15 -0700

> Given that this doesn't seem to be a widespread issue in the kernel
> personally I would consider the conversion to a macro in this case an
> acceptable solution, though it is definitely ugly. However I'm not the
> owner of the driver or the subsystem, so my opinion doesn't really
> carry much weight here ;-)

Losing type checking is a serious regression as far as I am concerned.
