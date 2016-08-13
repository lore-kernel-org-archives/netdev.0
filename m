From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/21] net: thunderx: Support for newer chips and
 miscellaneous patches
Date: Sat, 13 Aug 2016 12:01:22 -0700 (PDT)
Message-ID: <20160813.120122.1295172335050799161.davem@davemloft.net>
References: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgoutham@cavium.com, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: sunil.kovvuri@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
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

From: sunil.kovvuri@gmail.com
Date: Fri, 12 Aug 2016 16:51:23 +0530

> This patch series adds support for VNIC on 81xx and 83xx SOCs.
> 81xx/83xx is different from 88xx in terms of capabilities and new type
> of interfaces supported (eg: QSGMII, RGMII) and have DLMs instead of
> QLMs which allows single BGX to have interfaces of different LMAC types.
> 
> Also included some patches which are common for all 88xx/81xx/83xx
> SOCs like using netdev's name while registering irqs, reset receive
> queue stats and some changes to use standard API for split buffer Rx
> packets, generating RSS key e.t.c
> 
> PS: Most of the patches were submitted earlier under different series but
> for some reason were not picked up by patchwork. Since new patches have been
> added in the meantime, resubmitting all as a new patchset.
> 
> Changes from v1:
> - Incorporated Yuval Mintz's suggestion to use generic API to set minimum
>   queue count i.e by using netif_get_num_default_rss_queues().
> - Resolved a compilation issue reported by test robot while compiling
>   patch 'Add support for 16 LMACs of 83xx'

Series applied.
