From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC PATCH v8 00/16] Provide a zero-copy method on KVM virtio-net.
Date: Sat, 31 Jul 2010 11:30:16 +0200
Message-ID: <201007311130.17000.arnd@arndb.de>
References: <1280402088-5849-1-git-send-email-xiaohui.xin@intel.com> <F2E9EB7348B8264F86B6AB8151CE2D791BAB307158@shsmsx502.ccr.corp.intel.com> <1280505112.9058.31.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Xin, Xiaohui" <xiaohui.xin@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1280505112.9058.31.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 30 July 2010 17:51:52 Shirley Ma wrote:
> On Fri, 2010-07-30 at 16:53 +0800, Xin, Xiaohui wrote:
> > >Since vhost-net already supports macvtap/tun backends, do you think
> > >whether it's better to implement zero copy in macvtap/tun than
> > inducing
> > >a new media passthrough device here?
> > >
> > 
> > I'm not sure if there will be more duplicated code in the kernel. 
> 
> I think it should be less duplicated code in the kernel if we use
> macvtap to support what media passthrough driver here. Since macvtap has
> support virtio_net head and offloading already, the only missing func is
> zero copy. Also QEMU supports macvtap, we just need add a zero copy flag
> in option.

Yes, I fully agree and that was one of the intended directions for
macvtap to start with. Thank you so much for following up on that,
I've long been planning to work on macvtap zero-copy myself but it's
now lower on my priorities, so it's good to hear that you made progress
on it, even if there are still performance issues.

	Arnd
