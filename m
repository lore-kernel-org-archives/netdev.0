From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/3] Fix stmmac-socfpga allmodconfig breakage in arm-soc
Date: Wed, 26 Mar 2014 22:54:40 +0100
Message-ID: <201403262254.41069.arnd@arndb.de>
References: <1395790482-3957-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org, dinh.linux@gmail.com,
 pawel.moll@arm.com, srinivas.kandagatla@st.com, netdev@vger.kernel.org,
 ijc+devicetree@hellion.org.uk, robh+dt@kernel.org, arm@kernel.org,
 galak@codeaurora.org, peppe.cavallaro@st.com, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: dinguyen@altera.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1395790482-3957-1-git-send-email-dinguyen@altera.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wednesday 26 March 2014, dinguyen@altera.com wrote:
> From: Dinh Nguyen <dinguyen@altera.com>
> 
> Hi,
> 
> These 3 patches are based on Arnd's patch to fix the allmodconfig for the
> dwmac-socfpga implementation. I just broke the patch out into drivers,
> dts, and dts documentation.
> 
> The original patch is here:
> http://lists.infradead.org/pipermail/linux-arm-kernel/2014-March/241518.html
> 
> Arnd mentioned that he was thinking about just removing the dwmac-socfpga
> and send out the new verion to the netdev tree, but I haven't seen it. So
> just in case this solution might work, here are the patches.
> 
> These patches are based on arm-soc/for-next.

Hi Dinh,

Thanks for putting these patches together. The problem I see with these
is that we have multiple conflicts between my changes and the other
patches that went into the netdev tree.

Originally, the idea was that David Miller gave his Ack to have
the patches merged through arm-soc, but I think that was a mistake,
and they should have been treated like the other patches for
the same driver, i.e. put the driver and binding changes into
netdev, and the dt changes into arm-soc.

If I apply your patches on top of the next/drivers branch, we get
conflicts for a handful of files, and get Linus to resolve them.
I tried applying my patch on Sunday, but backed it out because 
of this.

My preferred solution at this point would be to revert the driver
addition in the arm-soc tree and have David put the new version
in, but I don't know if he still takes patches like that for 3.15.

	Arnd
