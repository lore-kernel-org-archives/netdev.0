From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: Freescale FEC i.MX28 VLAN support?
Date: Wed, 14 May 2014 10:37:47 +0000
Message-ID: <af16d562c5674929a5d12f0625a5685a@BLUPR03MB373.namprd03.prod.outlook.com>
References: <5373418F.6090602@meduna.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stanislav Meduna <stano@meduna.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, Linux ARM Kernel
 <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <5373418F.6090602@meduna.org>
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

Hi, Stano,

From: Stanislav Meduna <stano@meduna.org> Data: Wednesday, May 14, 2014 6:13 PM
>To: linux-kernel@vger.kernel.org; netdev@vger.kernel.org; Linux ARM Kernel
>Subject: Freescale FEC i.MX28 VLAN support?
>
>Hi,
>
>is there any particular reason why the FEC_QUIRK_HAS_VLAN is only set for imx6q-
>fec ?
>
>According to the reference manual the VLAN support is also present in i.MX28 and
>the DMA descriptors look the same in this regard, but this is from eyeballing only,
>I did not try to play with it yet.
>
>The reason I am asking is that I am using a switch that can tag the frames
>according to the port a packet is received from/sent to and I would like to use
>that feature.
>
>Please Cc: me when replying.
>
>Thanks
>--
>                                Stano

Imx28 also support the feature, you can enable it.
HW only support detect VLAN packet. The function with the config just using software to remove VLAN tag while receiving one packet.

Thanks,
Andy
