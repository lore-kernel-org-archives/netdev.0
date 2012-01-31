From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: fec: correct phy_name buffer length when init
 phy_name
Date: Tue, 31 Jan 2012 16:18:02 -0500 (EST)
Message-ID: <20120131.161802.213839339147145725.davem@davemloft.net>
References: <1327910892-11251-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patches@linaro.org, netdev@vger.kernel.org, u.kleine-koenig@pengutronix.de,
 shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org,
 LW@KARO-electronics.de
To: richard.zhao@linaro.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1327910892-11251-1-git-send-email-richard.zhao@linaro.org>
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

From: Richard Zhao <richard.zhao@linaro.org>
Date: Mon, 30 Jan 2012 16:08:12 +0800

> Fix the bug that we got wrong phy_name on imx6q sabrelite board.
> snprintf used wrong length of phy_name.
> phy_name length is MII_BUS_ID_SIZE + 3 rather not MII_BUS_ID_SIZE.
> I change it to sizeof(phy_name).
> 
> Signed-off-by: Richard Zhao <richard.zhao@linaro.org>

Applied, thanks.
