From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v4 2/7] binding: Make "mdio-parent-bus" property from
 mandatory to optional
Date: Wed, 8 Jun 2016 14:39:23 -0500
Message-ID: <20160608193923.GA31492@rob-hp-laptop>
References: <1465216900-11755-1-git-send-email-pramod.kumar@broadcom.com>
 <1465216900-11755-3-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Pramod Kumar <pramod.kumar@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:36069 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424035AbcFHTja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 15:39:30 -0400
Content-Disposition: inline
In-Reply-To: <1465216900-11755-3-git-send-email-pramod.kumar@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 06, 2016 at 06:11:35PM +0530, Pramod Kumar wrote:
> Change "mdio-parent-bus" from mandatory section to optional
> as it won't be required by integrated MDIO multiplexer
> which has bus selection and mdio transaction generation logic,
> integrated inside.
> 
> Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
> ---
>  Documentation/devicetree/bindings/net/mdio-mux.txt | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

Acked-by: Rob Herring <robh@kernel.org>
