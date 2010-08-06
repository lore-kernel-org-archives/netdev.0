From: Michael Leun <lkml20100708@newton.leun.net>
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free
 (adding ipv6 address to interface)
Date: Fri, 6 Aug 2010 02:09:47 +0200
Message-ID: <20100806020947.3b7c66ac@xenia.leun.net>
References: <loom.20100708T183152-326@post.gmane.org>
	<20100709235744.GA12752@kroah.com>
	<20100710101540.2799c9ef@xenia.leun.net>
	<20100710140800.GA20424@kroah.com>
	<20100710165208.59272ae6@xenia.leun.net>
	<20100710235323.5336f627@xenia.leun.net>
	<20100711192939.1c25dcaf@xenia.leun.net>
	<20100804153543.56f6ecad@xenia.leun.net>
	<20100804214618.GA6289@kroah.com>
	<20100805001105.5a3453ed@xenia.leun.net>
	<m1lj8l29zm.fsf@fess.ebiederm.org>
	<20100805112538.60a46cb1@xenia.leun.net>
	<m1y6clz8ta.fsf_-_@fess.ebiederm.org>
	<20100805134707.0442a7b1@xenia.leun.net>
	<m1bp9g7ry0.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1bp9g7ry0.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 05 Aug 2010 12:57:59 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> What puzzles me is that on a slightly patched 2.6.32 (so sysfs works)
> and I am doing very similar things (openvpn tunnels, ipv6 to the
> network as a whole etc), and I am not seeing the infinite
> unregister_netdevice: messages you are talking about.

Hmmm, I think there are 2 possibilities:

- You send me a patch against plain 2.6.32, so I can check my
  scenarios against that kernel

or 

-  You could try yourself, its really just that few lines against a
  fresh booted system in a clean, easy to reproduce state

(Only, if you think that would yield useful information, of course).

> When a network device is removed most references to it are redirected
> to the loopback device so a normal network device should not see the
> worst of the problems.  That is why lo showed up.
> 
> In that context I'm a bit surprised you managed trigger a problem on
> veth1.

Difference was, when that message showed up with veth1, lo in that
namespace was down while testing. When lo was up it showed up on lo.

-- 
MfG,

Michael Leun
