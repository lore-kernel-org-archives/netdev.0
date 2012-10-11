From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH v2 1/4] net: mvneta: driver for Marvell Armada 370/XP
 network unit
Date: Thu, 11 Oct 2012 20:13:13 +0200
Message-ID: <20121011181312.GB3850@tarshish>
References: <1349969282-12676-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1349969282-12676-2-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Jason Cooper <jason@lakedaemon.net>, Rami Rosen <rosenr@marvell.com>,
 netdev@vger.kernel.org, Lennert Buytenhek <kernel@wantstofly.org>,
 Maen Suleiman <maen@marvell.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1349969282-12676-2-git-send-email-thomas.petazzoni@free-electrons.com>
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

Hi Thomas,

On Thu, Oct 11, 2012 at 05:27:59PM +0200, Thomas Petazzoni wrote:
> +module_param(mvneta_rxq_number, int, S_IRUGO);
> +module_param(mvneta_txq_number, int, S_IRUGO);
> +
> +module_param(mvneta_rxq_def, int, S_IRUGO);
> +module_param(mvneta_txq_def, int, S_IRUGO);

Since these are module params they need the driver name prefix when referenced 
in the kernel command line, so there should be no need for another "mvneta" 
prefix.

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
