From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 2/6] net: use core MTU range checking in
 wireless drivers
Date: Wed, 19 Oct 2016 09:38:33 +0200
Message-ID: <1476862713.5927.0.camel@sipsolutions.net>
References: <20161019023333.15760-1-jarod@redhat.com>
         <20161019023333.15760-3-jarod@redhat.com>
         (sfid-20161019_043512_692157_D515CD3E)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        Maya Erez <qca_merez@qca.qualcomm.com>,
        Simon Kelley <simon@thekelleys.org.uk>,
        Stanislav Yakovlev <stas.yakovlev@gmail.com>
To: Jarod Wilson <jarod@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161019023333.15760-3-jarod@redhat.com> (sfid-20161019_043512_692157_D515CD3E)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-10-18 at 22:33 -0400, Jarod Wilson wrote:
> - set max_mtu in wil6210 driver
> - set max_mtu in atmel driver
> - set min/max_mtu in cisco airo driver, remove airo_change_mtu
> - set min/max_mtu in ipw2100/ipw2200 drivers, remove
> libipw_change_mtu
> - set min/max_mtu in p80211netdev, remove wlan_change_mtu

I guess we should do the same in net/mac80211/iface.c?

johannes
