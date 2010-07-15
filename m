From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv4] netfilter: add CHECKSUM target
Date: Thu, 15 Jul 2010 17:22:10 +0200
Message-ID: <4C3F27A2.3030207@trash.net>
References: <20100715115217.GA6737@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Daniel P. Berrange" <berrange@redhat.com>,
	Jes Sorensen <Jes.Sorensen@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jan Engelhardt <jengelh@medozas.de>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100715115217.GA6737@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 15.07.2010 13:52, schrieb Michael S. Tsirkin:
> This adds a `CHECKSUM' target, which can be used in the iptables mangle
> table.
> 
> You can use this target to compute and fill in the checksum in
> a packet that lacks a checksum.  This is particularly useful,
> if you need to work around old applications such as dhcp clients,
> that do not work well with checksum offloads, but don't want to
> disable checksum offload in your device.
> 
> The problem happens in the field with virtualized applications.
> For reference, see Red Hat bz 605555, as well as
> http://www.spinics.net/lists/kvm/msg37660.html
> 
> Typical expected use (helps old dhclient binary running in a VM):
> iptables -A POSTROUTING -t mangle -p udp --dport bootpc \
> 	-j CHECKSUM --checksum-fill
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Includes fixes by Jan Engelhardt <jengelh@medozas.de>

Applied, thanks Michael.
