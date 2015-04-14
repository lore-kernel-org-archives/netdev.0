From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH linux-next 3/4] macvlan: fix possible NULL pointer
 dereference in macvlan_dev_get_iflink
Date: Tue, 14 Apr 2015 16:35:14 +0100
Message-ID: <20150414153514.GK7874@acer.localdomain>
References: <1429024817-21561-1-git-send-email-honli@redhat.com>
 <1429024817-21561-4-git-send-email-honli@redhat.com>
 <20150414152626.GJ7874@acer.localdomain>
 <20150414153239.GA21856@honli.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	davem@davemloft.net, alex.estrin@intel.com, dledford@redhat.com,
	edumazet@google.com, erezsh@mellanox.com,
	nicolas.dichtel@6wind.com, maheshb@google.com, jbenc@redhat.com,
	ebiederm@xmission.com, elfring@users.sourceforge.net,
	f.fainelli@gmail.com, linux@roeck-us.net, andrew@lunn.ch,
	sfeldma@gmail.com, alexander.h.duyck@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Honggang LI <honli@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150414153239.GA21856@honli.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14.04, Honggang LI wrote:
> On Tue, Apr 14, 2015 at 04:26:27PM +0100, Patrick McHardy wrote:
> > 
> > That is completely useless. vlan (=netdev_priv) can not be NULL as
> > netdev_priv() never returns NULL and vlan->lowerdev is always valid
> > because a macvlan wouldn't make much sense otherwise.
> 
> OK, please drop this patch.

Well, the fact that netdev_priv never return NULL implies all your
patches need to be redone.

And I suggest you check whether this condition can actually happen.
Just because it can in one driver says nothing at all about others.
