From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Report for 2.6.35-rc3-00262-g984bc96
Date: Tue, 6 Jul 2010 19:42:22 -0700
Message-ID: <20100706194222.fcf16e13.akpm@linux-foundation.org>
References: <20100701074052.GA3501@schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, dri-devel@lists.freedesktop.org,
	Maciej Rutecki <maciej.rutecki@gmail.com>
To: Nico Schottelius <nico-linux-2010-07-01@schottelius.org>
Return-path: <dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org>
In-Reply-To: <20100701074052.GA3501@schottelius.org>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Sender: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
Errors-To: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Jul 2010 09:40:52 +0200 Nico Schottelius <nico-linux-2010-07-01@schottelius.org> wrote:

> Good morning!
> 
> A short report on what's broken in 2.6.35-rc3-00262-g984bc96 with
> the Lenovo X201:

So you see two post-2.6.34 regressions?

> == xrandr ==
> 
> After using xrandr several times in xorg, the screen gets
> "fancy": blue/white/black changing patterns.
> Getting even more weired when changing to a conosle.
> 
> The only thing that keeps on working is the mouse cursor
> in xorg. This did not happen with 2.6.34-rcsomething, neither
> with 2.6.33 iirc.
> 
> This is a Intel Corporation Core Processor Integrated Graphics Controller (rev 02),
> attached xorg.log.

(cc dri-devel)

> == netlink/carrier messag ==
> 
> dhcpcd does not get updated when the link is established,
> need to restart it. 

(cc netdev)

> == suspend/resume (to ram) ==
> 
> So far no real crash! Only xorg is sometimes not coming up
> again, but this may be related to the first issue.
> 
> == wifi / intel 6000 ==
> 
> Works! Works! (Besides the netlink issue, which is annoying,
> but for all devices).
