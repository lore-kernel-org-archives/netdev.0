From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fsl: fec: fix build for mx23-only kernel
Date: Tue, 03 Jan 2012 13:48:51 -0500 (EST)
Message-ID: <20120103.134851.1069804762867901608.davem@davemloft.net>
References: <1325598407-14353-1-git-send-email-w.sang@pengutronix.de>
 <CAOMZO5BmKJP-3y_FxczuGwGfBR_3e2J9z3+gqzs-JDxOtR_PdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: fabio.estevam@freescale.com, netdev@vger.kernel.org, w.sang@pengutronix.de,
 u.kleine-koenig@pengutronix.de, shawn.guo@linaro.org,
 linux-arm-kernel@lists.infradead.org
To: festevam@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAOMZO5BmKJP-3y_FxczuGwGfBR_3e2J9z3+gqzs-JDxOtR_PdQ@mail.gmail.com>
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

From: Fabio Estevam <festevam@gmail.com>
Date: Tue, 3 Jan 2012 13:37:47 -0200

> On Tue, Jan 3, 2012 at 11:46 AM, Wolfram Sang <w.sang@pengutronix.de> wro=
te:
>> If one only selects mx23-based boards, compile fails:
>>
>> drivers/net/ethernet/freescale/fec.c:410:2: error: 'FEC_HASH_TABLE_HIGH'=
 undeclared (first use in this function)
>> drivers/net/ethernet/freescale/fec.c:411:2: error: 'FEC_HASH_TABLE_LOW' =
undeclared (first use in this function)
>>
>> This is because fec.h uses CONFIG_SOC_IMX28 to determine the register
>> layout of the core which makes sense since the MX23 does not have a fec.
>> However, Kconfig uses the broader ARCH_MXS symbol and this way even
>> makes the fec-driver default for MX23. Adapt Kconfig to use the more
>> precise SOC_IMX28 as well.
>>
>> Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
>> Cc: Fabio Estevam <fabio.estevam@freescale.com>
>> Cc: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>> Cc: Shawn Guo <shawn.guo@linaro.org>
>> Cc: David S. Miller <davem@davemloft.net>
> =

> Acked-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thanks.
