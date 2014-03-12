From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next V4 6/9] Altera TSE: Add main and header file
 for Altera Ethernet Driver
Date: Wed, 12 Mar 2014 13:42:42 -0700
Message-ID: <1394656962.3915.41.camel@joe-AO722>
References: <1394655334-29547-1-git-send-email-vbridgers2013@gmail.com>
	 <1394655334-29547-7-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, rob@landley.net
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1394655334-29547-7-git-send-email-vbridgers2013@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-03-12 at 15:15 -0500, Vince Bridgers wrote:
> This patch adds the main driver and header file for the Altera Triple
> Speed Ethernet driver.
[]
> diff --git a/drivers/net/ethernet/altera/altera_tse.h b/drivers/net/ethernet/altera/altera_tse.h
[]
> +/* MAC register Space. Note that some of these registers may or may not be
> + * present depending upon options chosen by the user when the core was
> + * configured and built. Please consult the Altera Triple Speed Ethernet User
> + * Guide for details.
> + */
> +struct altera_tse_mac {
> +	/* Bits 15:0: MegaCore function revision (0x0800). Bit 31:16: Customer
> +	 * specific revision
> +	 */
> +	unsigned int megacore_revision;
> +	/* Provides a memory location for user applications to test the device
> +	 * memory operation.
> +	 */
> +	unsigned int scratch_pad;
> +	/* The host processor uses this register to control and configure the
> +	 * MAC block
> +	 */
> +	unsigned int command_config;
> +	/* 32-bit primary MAC address word 0 bits 0 to 31 of the primary
> +	 * MAC address
> +	 */
> +	unsigned int mac_addr_0;
> +	/* 32-bit primary MAC address word 1 bits 32 to 47 of the primary
> +	 * MAC address
> +	 */

maybe all of these should be specifically sized using u32 like

	u32 mac_addr_0;


