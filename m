From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [RFT PATCH] net: axienet: Fix devm_ioremap_resource return value
 check
Date: Thu, 9 Jul 2015 14:03:58 -0700
Message-ID: <20150709210358.GG3129@xsjsorenbubuntu>
References: <1436448080-24775-1-git-send-email-k.kozlowski.k@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Michal Simek <michal.simek@xilinx.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: Krzysztof Kozlowski <k.kozlowski.k@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436448080-24775-1-git-send-email-k.kozlowski.k@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-07-09 at 10:21PM +0900, Krzysztof Kozlowski wrote:
> Value returned by devm_ioremap_resource() was checked for non-NULL bu=
t
> devm_ioremap_resource() returns IOMEM_ERR_PTR, not NULL. In case of
> error this could lead to dereference of ERR_PTR.
>=20
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski.k@gmail.com>
> Cc: <stable@vger.kernel.org>
> Fixes: 46aa27df8853 ("net: axienet: Use devm_* calls")
Reviewed-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>

	S=C3=B6ren
