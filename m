From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: Gianfar driver failing on MPC8641D based board
Date: Thu, 25 Feb 2010 20:49:35 +0300
Message-ID: <20100225174935.GA32370@oksana.dev.rtsoft.ru>
References: <4B6C2488.3060403@ge.com>
 <4B865176.7080806@ge.com>
 <4B86A97E.6050509@ge.com>
 <20100225165141.GA9686@oksana.dev.rtsoft.ru>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	davem@davemloft.net, Kumar Gala <galak@kernel.crashing.org>
To: Martyn Welch <martyn.welch@ge.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100225165141.GA9686@oksana.dev.rtsoft.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 25, 2010 at 07:51:41PM +0300, Anton Vorontsov wrote:
> On Thu, Feb 25, 2010 at 04:46:54PM +0000, Martyn Welch wrote:
> [...]
> > > nfs: server 192.168.0.1 not responding, still trying
> > >   
> > 
> > Further testing has shown that this isn't restricted to warm reboots, it
> > happens from cold as well. In addition, the exact timing of the failure
> > seems to vary, some boots have got further before failing.
> 
> Unfortunately I don't have any 8641 boards near me, so I can't
> debug this myself. Though, I tested gianfar on MPC8568E-MDS with
> 2.6.33 kernel, and it seems to work just fine.
> 
> I see you use SMP. Can you try to turn it off? If that will fix
> the issue, then it'll be a good data point.
> 
> Meanwhile, I'll try SMP kernel on MPC8568 (UP), and let you
> know the results.

Nope, no luck. Can't trigger the issue. :-/
Tested with NFS boot, TCP and UDP netperf tests.

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
