From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: How to deal with a PHY configuration related to the board?
Date: Tue, 14 Feb 2012 11:43:39 +0200
Message-ID: <20120214094339.GA4338@sapphire.tkos.co.il>
References: <20120214092606.GE4723@ldesroches-Latitude-E6320>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Ferre, Nicolas" <nicolas.ferre@atmel.com>,
 linux-arm-kernel@lists.infradead.org
To: Ludovic Desroches <ludovic.desroches@atmel.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20120214092606.GE4723@ldesroches-Latitude-E6320>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Ludovic,

On Tue, Feb 14, 2012 at 10:26:06AM +0100, Ludovic Desroches wrote:
> I am using a Micrel KSZ9021RN PHY and I would like to configure some 
> registers
> as 'RGMII Clock and Control Pad Skew' and 'RGMII RX Data Pad Skew'.
> So the values of these registers are board dependant and I wondering what is
> the proper way to set them.
> It seems there is no platform data usable for this case. Having a quick look
> to other PHYs, the situation seems the same.
> 
> Can you give me some clues about how to do this? Did I miss anything which
> allow to do this?

See ksz9021rn_phy_fixup() in arch/arm/mach-imx/mach-imx6q.c.

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
