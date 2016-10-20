From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next v2 3/9] net: use core MTU range checking in
 wireless drivers
Date: Thu, 20 Oct 2016 20:22:35 +0200
Message-ID: <1476987755.14078.3.camel@sipsolutions.net>
References: <20161019023333.15760-1-jarod@redhat.com>
         <20161020175524.6184-1-jarod@redhat.com>
         <20161020175524.6184-4-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        Maya Erez <qca_merez@qca.qualcomm.com>,
        Simon Kelley <simon@thekelleys.org.uk>,
        Stanislav Yakovlev <stas.yakovlev@gmail.com>,
        Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
To: Jarod Wilson <jarod@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161020175524.6184-4-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-10-20 at 13:55 -0400, Jarod Wilson wrote:
> - set max_mtu in wil6210 driver
> - set max_mtu in atmel driver
> - set min/max_mtu in cisco airo driver, remove airo_change_mtu
> - set min/max_mtu in ipw2100/ipw2200 drivers, remove
> libipw_change_mtu
> - set min/max_mtu in p80211netdev, remove wlan_change_mtu
> - set min/max_mtu in net/mac80211/iface.c and remove ieee80211_change_mtu

For the mac80211 part,

Acked-by: Johannes Berg <johannes@sipsolutions.net>

Dave, I'm assuming you'll pick this up, but if you prefer not to I can
also coordinate with Kalle to take this through our trees.

johannes
