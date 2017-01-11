From: <Andrei.Pistirica@microchip.com>
Subject: RE: [RFC PATCH net-next v4 1/2] macb: Add 1588 support in Cadence GEM.
Date: Wed, 11 Jan 2017 14:34:13 +0000
Message-ID: <07C910AB6AC6C345A093D5A08F5AF568CB77996E@CHN-SV-EXMX03.mchp-main.com>
References: <1481720175-12703-1-git-send-email-andrei.pistirica@microchip.com>
 <BN3PR07MB2516815EDE69ACDCE27F81A3C96F0@BN3PR07MB2516.namprd07.prod.outlook.com>
 <20170102113155.GA16373@localhost.localdomain>
 <0717c63b-2e29-9ad1-7f01-39817980933f@atmel.com>
 <20170102161359.GD3609@localhost.localdomain>
 <CAFcVECK1vt7Hu4tgSZ2+kKpMxoT-wpikMDq65HaxRv-EMgobHA@mail.gmail.com>
 <BN3PR07MB25168573DD82F1681CDC8437C96E0@BN3PR07MB2516.namprd07.prod.outlook.com>
 <20170103111447.GA26488@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tbultel@pixelsurmer.com, boris.brezillon@free-electrons.com,
 netdev@vger.kernel.org, alexandre.belloni@free-electrons.com,
 linux-kernel@vger.kernel.org, michals@xilinx.com, anirudh@xilinx.com,
 punnaia@xilinx.com, davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: <richardcochran@gmail.com>, <rafalo@cadence.com>,
 <harinikatakamlinux@gmail.com>, <nicolas.ferre@atmel.com>,
 <harini.katakam@xilinx.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170103111447.GA26488@localhost.localdomain>
Content-Language: en-US
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

 
> On Tue, Jan 03, 2017 at 10:47:56AM +0000, Rafal Ozieblo wrote:
> > We could use only descriptor approach but there are many Atmel's cores
> on the market which support only event registers.
> 
> As I said in my other reply in this thread, the Atmel cores cannot possibly be
> made to work correctly.
> 
> Sad, but true.

In conscience, I will make a patch containing only the common code (just to benefit from this effort) and then Rafal can add the driver for the GXL version on top of it.
Everybody agrees with this?

Best regards,
Andrei

> 
> Thanks,
> Richard
