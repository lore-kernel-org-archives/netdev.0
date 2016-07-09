From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net-next] netvsc: Use the new in-place
 consumption APIs in the rx path
Date: Fri, 08 Jul 2016 23:12:21 -0400 (EDT)
Message-ID: <20160708.231221.2165509764297884160.davem@davemloft.net>
References: <1467762766-1442-1-git-send-email-kys@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org,
 leann.ogasawara@canonical.com
To: kys@exchange.microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1467762766-1442-1-git-send-email-kys@exchange.microsoft.com>
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

From: kys@exchange.microsoft.com
Date: Tue,  5 Jul 2016 16:52:46 -0700

> From: K. Y. Srinivasan <kys@microsoft.com>
> 
> Use the new APIs for eliminating a copy on the receive path. These new APIs also
> help in minimizing the number of memory barriers we end up issuing (in the
> ringbuffer code) since we can better control when we want to expose the ring
> state to the host.
> 
> The patch is being resent to address earlier email issues.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
