From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] Add device tree probe support for imx fec driver
Date: Tue, 05 Jul 2011 22:30:45 -0700 (PDT)
Message-ID: <20110705.223045.738515407552627580.davem@davemloft.net>
References: <1309878839-25743-1-git-send-email-shawn.guo@linaro.org>
	<20110705.194854.1875695946300840388.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org, patches@linaro.org
To: shawn.guo@linaro.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20110705.194854.1875695946300840388.davem@davemloft.net>
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

From: David Miller <davem@davemloft.net>
Date: Tue, 05 Jul 2011 19:48:54 -0700 (PDT)

> All applied to net-next-2.6, thanks.

Come on guys:

drivers/of/of_net.c: In function 'of_get_phy_mode':
drivers/of/of_net.c:45: error: implicit declaration of function 'of_property_read_string'

This is completely rediculious.

Don't tell me that it's appropriate to merge something into
my net tree when it uses interfaces that don't even exist
in Linus's tree.
