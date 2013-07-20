From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: Re: [PATCH] net: Add MOXA ART SoCs ethernet driver
Date: Sat, 20 Jul 2013 12:55:36 +0200
Message-ID: <CACmBeS0ztqKWJ1uLKhb2EZdexspTq5t0uHZfPotHiAPHfkftoA@mail.gmail.com>
References: <1374140806-12485-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	arm@kernel.org, Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1374140806-12485-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think this driver may have a bug.

After some time running ping successfully, the message "no TX space
for packet" is printed resulting in 100% packet loss.

The message is printed from .ndo_start_xmit and I think it may be
because of how priv->tx_desc_now is now set up in
moxart_mac_setup_desc_ring.

I will take a look at this and try to fix the issue.

Best regards,
Jonas
