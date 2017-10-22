From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/15] networking drivers refcount_t conversions
Date: Sun, 22 Oct 2017 02:31:32 +0100 (WEST)
Message-ID: <20171022.023132.2040144937883625039.davem@davemloft.net>
References: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-rdma@vger.kernel.org,
        linux-hams@vger.kernel.org, linux-ppp@vger.kernel.org,
        ganeshgr@chelsio.com, nbd@openwrt.org, john@phrozen.org,
        sean.wang@mediatek.com, matthias.bgg@gmail.com,
        yishaih@mellanox.com, saeedm@mellanox.com, matanb@mellanox.com,
        tariqt@mellanox.com, leonro@mellanox.com,
        ajk@comnets.uni-bremen.de, paulus@samba.org, zbr@ioremap.net,
        peterz@infradead.org, keescook@chromium.org
To: elena.reshetova@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Elena Reshetova <elena.reshetova@intel.com>
Date: Fri, 20 Oct 2017 10:23:34 +0300

> Note: these are the last patches related to networking that perform
> conversion of refcounters from atomic_t to refcount_t.
> In contrast to the core network refcounter conversions that
> were merged earlier, these are much more straightforward ones.
> 
> This series, for various networking drivers, replaces atomic_t reference
> counters with the new refcount_t type and API (see include/linux/refcount.h).
> By doing this we prevent intentional or accidental
> underflows or overflows that can led to use-after-free vulnerabilities.
> 
> The patches are fully independent and can be cherry-picked separately.
> Patches are based on top of net-next.
> If there are no objections to the patches, please merge them via respective trees

I've applied this entire series to net-next.  If there are any fixups or
follow-ups please send them as relative patches.

Thank you.
