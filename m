From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Divide error in bictcp_cong_avoid ?
Date: Wed, 4 May 2011 11:33:51 -0700
Message-ID: <20110504113351.4643a0c9@nehalam>
References: <4DC178D3.6030308@techboom.com>
	<20110504104940.cd0d9e9a.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: TB <lkml@techboom.com>, netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110504104940.cd0d9e9a.rdunlap@xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 May 2011 10:49:40 -0700
Randy Dunlap <rdunlap@xenotime.net> wrote:

> [add cc to netdev]
> 
> 
> On Wed, 04 May 2011 12:03:31 -0400 TB wrote:
> 
> > We're having this issue sporadically on a few servers and this is the 
> > backtrace we get from netconsole.
> > 
> > 
> > [28522.642419] divide error: 0000 [#1] SMP
> > [28522.642457] last sysfs file: 
> > /sys/devices/pci0000:00/0000:00:1f.2/host2/target2:0:0/2:0:0:0/vendor
> > [28522.642504] CPU 0
> > [28522.642511] Modules linked in:
> >   i2c_i801
> >   i2c_core
> >   evdev
> >   button
> > [28522.642570]
> > [28522.642590] Pid: 0, comm: swapper Not tainted 2.6.38.5 #6
> > 
> >   Supermicro X8DTH-i/6/iF/6F
> > /
> >   X8DTH
> > 

What kernel version? I suspect they are running something really old
kernel like RHEL 5 since BIC has not been the default congestion control for
several years.

-- 
