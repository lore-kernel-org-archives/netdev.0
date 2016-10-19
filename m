From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next 2/6] net: use core MTU range checking in
 wireless drivers
Date: Wed, 19 Oct 2016 10:27:06 -0400
Message-ID: <20161019142706.GE18569@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161019023333.15760-3-jarod@redhat.com>
 <1476862713.5927.0.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Maya Erez <qca_merez@qca.qualcomm.com>,
        Simon Kelley <simon@thekelleys.org.uk>,
        Stanislav Yakovlev <stas.yakovlev@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1476862713.5927.0.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 19, 2016 at 09:38:33AM +0200, Johannes Berg wrote:
> On Tue, 2016-10-18 at 22:33 -0400, Jarod Wilson wrote:
> > - set max_mtu in wil6210 driver
> > - set max_mtu in atmel driver
> > - set min/max_mtu in cisco airo driver, remove airo_change_mtu
> > - set min/max_mtu in ipw2100/ipw2200 drivers, remove
> > libipw_change_mtu
> > - set min/max_mtu in p80211netdev, remove wlan_change_mtu
> 
> I guess we should do the same in net/mac80211/iface.c?

Yeah. I thought I'd located all places this needed to happen, but
obviously not. I'll get this added and do another sweep for others I might
have missed.

-- 
Jarod Wilson
jarod@redhat.com
