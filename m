From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] /net/ax25/: some cleanups
Date: Tue, 28 Dec 2004 10:05:07 -0800
Message-ID: <20041228100507.7b374b5e.davem@davemloft.net>
References: <20041212211339.GX22324@stusta.de>
	<20041227185151.2a7ceb71.davem@davemloft.net>
	<1104237408.20944.70.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1104237408.20944.70.camel@localhost.localdomain>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Dec 2004 14:27:08 +0000
Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> On Maw, 2004-12-28 at 02:51, David S. Miller wrote:
> > On Sun, 12 Dec 2004 22:13:39 +0100
> > Adrian Bunk <bunk@stusta.de> wrote:
> > 
> > > The patch below contains the following cleanups:
> > > - make two needlessly global functions static
> > > - net/ax25/ax25_addr.c: remove the unused global function ax25digicmp
> 
> Dave this function is only unused because a patch in 2.6.10 broke AX.25
> protocol support by removing the device and path checks. AX.25 is a link
> layer protocol it is supposed to check the devices and arguably the
> path. 

Send a patch to netdev and CC: me to fix this as is standard
procedure for getting changes into the networking.  :-)


