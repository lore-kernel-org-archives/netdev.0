From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [2.6 patch] /net/ax25/: some cleanups
Date: Tue, 28 Dec 2004 14:27:08 +0000
Message-ID: <1104237408.20944.70.camel@localhost.localdomain>
References: <20041212211339.GX22324@stusta.de>
	 <20041227185151.2a7ceb71.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, ralf@linux-mips.org,
        linux-hams@vger.kernel.org, netdev@oss.sgi.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041227185151.2a7ceb71.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Maw, 2004-12-28 at 02:51, David S. Miller wrote:
> On Sun, 12 Dec 2004 22:13:39 +0100
> Adrian Bunk <bunk@stusta.de> wrote:
> 
> > The patch below contains the following cleanups:
> > - make two needlessly global functions static
> > - net/ax25/ax25_addr.c: remove the unused global function ax25digicmp

Dave this function is only unused because a patch in 2.6.10 broke AX.25
protocol support by removing the device and path checks. AX.25 is a link
layer protocol it is supposed to check the devices and arguably the
path. 
