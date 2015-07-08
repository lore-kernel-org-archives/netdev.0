From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,v2] hv_netvsc: Add support to set MTU
 reservation from guest side
Date: Wed, 08 Jul 2015 16:01:14 -0700 (PDT)
Message-ID: <20150708.160114.358447538011441747.davem@davemloft.net>
References: <1436217097-31102-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1436217097-31102-1-git-send-email-haiyangz@microsoft.com>
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

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Mon,  6 Jul 2015 14:11:37 -0700

> When packet encapsulation is in use, the MTU needs to be reduced for
> headroom reservation.
> The existing code takes the updated MTU value only from the host side.
> But vSwitch extensions, such as Open vSwitch, require the flexibility
> to change the MTU to different values from within a guest during the
> lifecycle of a vNIC, when the encapsulation protocol is changed. The
> patch supports this kind of MTU changes.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied, thanks.
