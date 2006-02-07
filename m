From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: IBM_EMAC_PHY_RX_CLK_FIX depends on non-existing option 440GR
Date: Tue, 7 Feb 2006 14:57:13 -0800
Message-ID: <20060207225713.GA6933@gate.ebshome.net>
References: <20060207221449.GB3524@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jean-Luc Leger <reiga@dspnet.fr.eu.org>,
	linuxppc-embedded@ozlabs.org
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060207221449.GB3524@stusta.de>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 07, 2006 at 11:14:49PM +0100, Adrian Bunk wrote:
> Jean-Luc Leger <reiga@dspnet.fr.eu.org> reported the following:
> 
> from drivers/net/Kconfig:
> config IBM_EMAC_PHY_RX_CLK_FIX
>         bool "PHY Rx clock workaround"
>         depends on IBM_EMAC && (405EP || 440GX || 440EP || 440GR)
> -> maybe this is 440GP ?
> 
> 
> The non-existing CONFIG_440GR is also present in the driver itself.
> 
> Is this a typo or a not yet merged platform?

Not yet merged platform.

-- 
Eugene
