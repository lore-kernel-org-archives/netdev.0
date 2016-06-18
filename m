From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/2] net: ethernet: ti: cpsw: delete rx_descs
 property
Date: Fri, 17 Jun 2016 21:28:11 -0700 (PDT)
Message-ID: <20160617.212811.1535969626992239666.davem@davemloft.net>
References: <1466159140-3329-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, linux-kernel@vger.kernel.org,
	grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, bcousson@baylibre.com, tony@atomide.com,
	devicetree@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466159140-3329-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Fri, 17 Jun 2016 13:25:38 +0300

> There is no reason in rx_descs property because davinici_cpdma
> driver splits pool of descriptors equally between tx and rx channels.
> So, this patch series makes driver to use available number of
> descriptors for rx channels.
> 
> Based on
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
> master
> 
> Since v2:
> - add declaration of buf_num in correct order

Series applied, thanks.
