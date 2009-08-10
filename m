From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] macvlan: add tap device backend
Date: Mon, 10 Aug 2009 20:43:32 +0200
Message-ID: <200908102043.32937.arnd@arndb.de>
References: <1249595428-21594-1-git-send-email-arnd@arndb.de> <4A7FC27F.1090904@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"" <davem@davemloft.net>, "Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@voltaire.com>,
	"Fischer, Anna" <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Edge Virtual Bridging <evb@yahoogroups.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752970AbZHJSo3@vger.kernel.org>
In-Reply-To: <4A7FC27F.1090904@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 10 August 2009, Patrick McHardy wrote:

> macvlan will remove all macvlan/vtap devices when the underlying
> device in unregistered, at which time you need to release the
> device references you're holding. I'd suggest to change the
> macvlan_device_event() handler to use
> 
> vlan->dev->rtnl_link_ops->dellink(vlan->dev)
> 
> instead of macvlan_dellink() so the macvtap_dellink callback
> is invoked.

Ok, will do that. Thanks,

	Arnd <><
