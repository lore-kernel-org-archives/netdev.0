From: =?UTF-8?B?QWxleGFuZGVyIFNoaXlhbg==?= <shc_work@mail.ru>
Subject: =?UTF-8?B?UmU6IFtQQVRDSCAxLzNdIGNhbjogbWNwMjUxeDogQ29udmVydCBkcml2ZXIg?=
 =?UTF-8?B?dG8gdXNlIGNvbW1vbiBjbGsgZnJhbWV3b3Jr?=
Date: Sat, 14 Dec 2013 17:35:23 +0400
Message-ID: <1387028123.883417068@f330.i.mail.ru>
References: <1384332144-15211-1-git-send-email-shc_work@mail.ru>
 <20131214091507.35557bcf132c885cfba69008@mail.ru>
 <52AC5A9D.3010703@pengutronix.de>
Reply-To: =?UTF-8?B?QWxleGFuZGVyIFNoaXlhbg==?= <shc_work@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?UnVzc2VsbCBLaW5n?= <linux@arm.linux.org.uk>, dbaryshkov@gmail.com,
 netdev@vger.kernel.org,
 =?UTF-8?B?SGFvamlhbiBaaHVhbmc=?= <haojian.zhuang@gmail.com>,
 linux-can@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 =?UTF-8?B?U2FzY2hhIEhhdWVy?= <kernel@pengutronix.de>,
 =?UTF-8?B?RXJpYyBNaWFv?= <eric.y.miao@gmail.com>,
 =?UTF-8?B?V29sZmdhbmcgR3JhbmRlZ2dlcg==?= <wg@grandegger.com>
To: =?UTF-8?B?TWFyYyBLbGVpbmUtQnVkZGU=?= <mkl@pengutronix.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <52AC5A9D.3010703@pengutronix.de>
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

> On 12/14/2013 06:15 AM, Alexander Shiyan wrote:
> > On Wed, 13 Nov 2013 10:04:39 +0100
> > Marc Kleine-Budde <mkl@pengutronix.de> wrote:
> > 
> >> as this series adds device tree bindings, please add
> >> devicetree@vger.kernel.org on Cc for the whole series.
> >>
> >> On 11/13/2013 09:42 AM, Alexander Shiyan wrote:
> >>> This patch converts mcp251x driver to using common clk framework
> >>> for getting input frequency. The change was made for the preparation
> >>> of the driver work with the devicetree. As a result private header
> >>> for the driver is eliminated.
> >>> Additionally, all existing users of the driver was converted to use
> >>> this feature.
> >>>
> >>> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
> >>
> >> Looks good from my point of view. I'll take the whole series via the
> >> linux-can tree, if there are no objections. I'd like to have the pxa and
> >> imx maintainer's Ack and an Ack from the DT list.
> >>
> >> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
> > 
> > Ping. Resend?
> 
> Is Dmitry's comment still valid?
> 
> PXA does not employ COMMON_CLK yet (WIP locally, but it is not finished
> yet), so clk_register_fixed() will probably fail.

OK, I'll make another version then.

---
