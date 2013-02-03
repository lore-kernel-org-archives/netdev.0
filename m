From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: don't return zero on failure path in
 stmmac_pci_probe()
Date: Sun, 03 Feb 2013 16:14:30 -0500 (EST)
Message-ID: <20130203.161430.1661232701671861013.davem@davemloft.net>
References: <1359756559-20211-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359756559-20211-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat,  2 Feb 2013 02:09:19 +0400

> If stmmac_dvr_probe() fails in stmmac_pci_probe(), it breaks off initialization,
> deallocates all resources, but returns zero.
> The patch adds -ENODEV as return value in this case.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied to net-next, thanks.
