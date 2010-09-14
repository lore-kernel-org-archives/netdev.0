From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.36-rc4/iwl: warning triggered in net/mac80211/scan.c:266
Date: Tue, 14 Sep 2010 21:43:10 +0200
Message-ID: <1284493390.3703.1.camel@jlt3.sipsolutions.net>
References: <20100914142814.GA8744@redhat.com>
	 <1284474988.3704.10.camel@jlt3.sipsolutions.net>
	 <20100914151439.GA13028@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Reinette Chatre <reinette.chatre@intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100914151439.GA13028@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-09-14 at 17:14 +0200, Michael S. Tsirkin wrote:

> > No, it shouldn't happen. But there are various races in iwlwifi that can
> > cause this. Stanislaw has fixed them recently, but it's a fairly large
> > patchset. I'm not sure, but I don't think this is really new in .36.

> So ... get back to you after 2.6.37?

Err, yes, I guess so, though I suppose it doesn't really solve the
problem. This particular instance should be harmless though, I believe,
other than the warning.

johannes
