From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: mvneta: properly disable HW PHY polling and ensure
 adjust_link() works
Date: Wed, 4 Sep 2013 18:32:45 +0200
Message-ID: <20130904163245.GI20552@1wt.eu>
References: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>,
 Jochen De Smet <jochen.armkernel@leahnim.org>,
 Simon Guinot <simon.guinot@sequanux.org>, Ryan Press <ryan@presslab.us>,
 netdev@vger.kernel.org, vdonnefort@lacie.com,
 Ethan Tuttle <ethan@ethantuttle.com>, stable@vger.kernel.org,
 Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
 =?iso-8859-1?Q?Ch=E9ny?= Yves-Gael <yves@cheny.fr>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Peter Sanford <psanford@nearbuy.io>, "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com>
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

Hi Thomas!

On Wed, Sep 04, 2013 at 04:21:18PM +0200, Thomas Petazzoni wrote:
> This commit fixes a long-standing bug that has been reported by many
> users: on some Armada 370 platforms, only the network interface that
> has been used in U-Boot to tftp the kernel works properly in
> Linux. The other network interfaces can see a 'link up', but are
> unable to transmit data. The reports were generally made on the Armada
> 370-based Mirabox, but have also been given on the Armada 370-RD
> board.
(...)
> This patch has been tested on Armada 370 Mirabox, and now both network
> interfaces are usable after boot.

Just as a complementary check, I can also confirm that the OpenBlocks
AX3 continues to work fine after this change.

Best regards!
Willy
