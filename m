From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC v2 2/4] net: enables interface option to skip IP
Date: Tue, 18 Feb 2014 13:42:57 -0800
Message-ID: <20140218134257.667efe23@nehalam.linuxnetplumber.net>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
	<1392433180-16052-3-git-send-email-mcgrof@do-not-panic.com>
	<1392668638.21106.5.camel@dcbw.local>
	<CAB=NE6XGBp1RwO63W0ac6tTr9JcRM9TB9sap4pa+8PMWwjxu6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel@lists.xenproject.org, kvm@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6XGBp1RwO63W0ac6tTr9JcRM9TB9sap4pa+8PMWwjxu6g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Feb 2014 13:19:15 -0800
"Luis R. Rodriguez" <mcgrof@do-not-panic.com> wrote:

> Sure, but note that the both disable_ipv6 and accept_dada sysctl
> parameters are global. ipv4 and ipv6 interfaces are created upon
> NETDEVICE_REGISTER, which will get triggered when a driver calls
> register_netdev(). The goal of this patch was to enable an early
> optimization for drivers that have no need ever for ipv4 or ipv6
> interfaces.

The trick with ipv6 is to register the device, then have userspace
do the ipv6 sysctl before bringing the device up.
