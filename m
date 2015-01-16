From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ethernet: atheros: Add nss-gmac driver
Date: Thu, 15 Jan 2015 17:58:30 -0800
Message-ID: <20150115175830.5210cfb8@urahara>
References: <y>
	<1420754626-30121-1-git-send-email-wstephen@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, grant.likely@linaro.org, robh+dt@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Stephen Wang <wstephen@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420754626-30121-1-git-send-email-wstephen@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu,  8 Jan 2015 14:03:46 -0800
Stephen Wang <wstephen@codeaurora.org> wrote:

> +	struct nss_gmac_data_plane_ops *data_plane_ops;
> +					/* ops to send messages to nss-drv    */

This should be a const pointer.
