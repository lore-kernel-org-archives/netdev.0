From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v3 0/2] net: ethernet: ti: cpsw: delete rx_descs property
Date: Fri, 17 Jun 2016 20:38:50 +0530
Message-ID: <57641282.9070002@ti.com>
References: <1466159140-3329-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <grygorii.strashko@ti.com>, <linux-omap@vger.kernel.org>,
	<netdev@vger.kernel.org>, <robh+dt@kernel.org>,
	<pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<bcousson@baylibre.com>, <tony@atomide.com>,
	<devicetree@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466159140-3329-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 17 June 2016 03:55 PM, Ivan Khoronzhuk wrote:
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
> 
> Since v1:
> - separate device tree and driver patches
> - return number of rx buffers from cpdma driver
> 

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
