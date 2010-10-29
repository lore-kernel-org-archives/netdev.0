From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] macvlan: Introduce 'passthru' mode to takeover the underlying device
Date: Fri, 29 Oct 2010 15:45:17 +0200
Message-ID: <201010291545.17910.arnd@arndb.de>
References: <1288307450.30131.82.camel@sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1288307450.30131.82.camel@sridhar.beaverton.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 29 October 2010, Sridhar Samudrala wrote:
> With the current default 'vepa' mode, a KVM guest using virtio with 
> macvtap backend has the following limitations.
> - cannot change/add a mac address on the guest virtio-net

I believe this could be changed if there is a neeed, but I actually
consider it one of the design points of macvlan that the guest
is not able to change the mac address. With 802.1Qbg you rely on
the switch being able to identify the guest by its MAC address,
which the host kernel must ensure.

> - cannot create a vlan device on the guest virtio-net

Why not? If this doesn't work, it's probably a bug!
Why does the passthru mode enable it if it doesn't work
already?

> - cannot enable promiscuous mode on guest virtio-net

Could you elaborate why such a setup would be useful?

	Arnd

