From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 1/1] hyperv: Properly handle checksum offload
Date: Wed, 30 Apr 2014 13:34:10 -0400 (EDT)
Message-ID: <20140430.133410.981284387859397046.davem@davemloft.net>
References: <1398873921-20955-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org,
 stable@kernel.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1398873921-20955-1-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Wed, 30 Apr 2014 09:05:21 -0700

> Do checksum offload only if the client of the driver wants checksum to be
> offloaded.
> 
> In V1 version of this patch, I  addressed comments from
> Stephen Hemminger <stephen@networkplumber.org> and
> Eric Dumazet <eric.dumazet@gmail.com>.
> 
> In this version of the patch I have addressed comments from
> David Miller.
> 
> This patch fixes a bug that is exposed in gateway scenarios.
> 
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>

It does not make any sense to submit a patch for net-next and
also ask for it to be included in -stable.

First of all, -stable submissions are handled by me directly for
networking.  Therefore you should not CC: stable on such patches,
instead you ask me politly to include it in my stable submission
queue.

Second of all, if a patch is destined for stable, it should be
submitted for 'net' not 'net-next'.
