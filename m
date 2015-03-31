From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] hv_netvsc: Eliminate memory allocation in
 the send path
Date: Tue, 31 Mar 2015 14:12:52 -0400 (EDT)
Message-ID: <20150331.141252.1285173813259299502.davem@davemloft.net>
References: <1427688478-27950-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1427688478-27950-1-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Sun, 29 Mar 2015 21:07:58 -0700

> The network protocol used to communicate with the host is the remote ndis (rndis)
> protocol. We need to decorate each outgoing packet with a rndis header and
> additional rndis state (rndis per-packet state). To manage this state, we
> currently allocate memory in the transmit path. Eliminate this allocation by
> requesting additional head room in the skb.

Series applied, thanks.
