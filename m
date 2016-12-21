From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: Re: at86rf230: Allow slow GPIO pins for "rstn"
Date: Wed, 21 Dec 2016 15:30:52 +0300
Message-ID: <1482323452-10642-1-git-send-email-nikita.yoush@cogentembedded.com>
References: <1482103533-13187-1-git-send-email-andrew.smirnov@gmail.com>
Cc: Andrey Smirnov <andrew.smirnov@gmail.com>,
        Alexander Aring <aar@pengutronix.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Chris Healy <cphealy@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>
To: linux-wpan@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482103533-13187-1-git-send-email-andrew.smirnov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Driver code never touches "rstn" signal in atomic context, so there's
> no need to implicitly put such restriction on it by using gpio_set_value
> to manipulate it. Replace gpio_set_value to gpio_set_value_cansleep to
> fix that.
> 
> As a an example of where such restriction might be inconvenient,
> consider a hardware design where "rstn" is connected to a pin of I2C/SPI
> GPIO expander chip.
> 
> Cc: Chris Healy <cphealy@gmail.com>
> Signed-off-by: Andrey Smirnov <andrew.smirnov@gmail.com>

Reviewed-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
