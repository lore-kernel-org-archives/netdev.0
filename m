From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] mvneta xmit_more and bql support
Date: Mon, 16 Jan 2017 20:13:25 -0500 (EST)
Message-ID: <20170116.201325.2191165766691361664.davem@davemloft.net>
References: <1484586512-16412-1-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch, linux@arm.linux.org.uk,
 jason@lakedaemon.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 jaz@semihalf.com, gregory.clement@free-electrons.com,
 linux-arm-kernel@lists.infradead.org, sebastian.hesselbarth@gmail.com
To: mw@semihalf.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1484586512-16412-1-git-send-email-mw@semihalf.com>
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

From: Marcin Wojtas <mw@semihalf.com>
Date: Mon, 16 Jan 2017 18:08:30 +0100

> This is a delayed v2 of short patchset, which introduces xmit_more and BQL
> to mvneta driver. The only one change was added in xmit_more support -
> condition check preventing excessive descriptors concatenation before
> flushing in HW.
> 
> Any comments or feedback would be welcome.
 ...
> Changelog:
> v1 -> v2:
> 
> * Add checking condition that ensures too much descriptors are not
>   concatenated before flushing in HW.

Looks good, series applied, thanks.
