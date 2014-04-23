From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,v2,1/2] hyperv: Remove recv_pkt_list and lock
Date: Wed, 23 Apr 2014 14:49:07 -0400 (EDT)
Message-ID: <20140423.144907.2086744325555588840.davem@davemloft.net>
References: <1398117284-5236-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1398117284-5236-1-git-send-email-haiyangz@microsoft.com>
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

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Mon, 21 Apr 2014 14:54:43 -0700

> Removed recv_pkt_list and lock, and updated related code, so that
> the locking overhead is reduced especially when multiple channels
> are in use.
> 
> The recv_pkt_list isn't actually necessary because the packets are
> processed sequentially in each channel. It has been replaced by a
> local variable, and the related lock for this list is also removed.
> The is_data_pkt field is not used in receive path, so its assignment
> is cleaned up.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
