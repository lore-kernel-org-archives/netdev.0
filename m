From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: page allocation failure
Date: Sat, 16 Oct 2004 23:49:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041016214903.GC21849@electric-eye.fr.zoreil.com>
References: <200410162004.17573.jkillius@arcor.de> <20041016204848.GB21849@electric-eye.fr.zoreil.com> <200410162304.38905.jkillius@arcor.de> <200410162323.01006.jkillius@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Killius <jkillius@arcor.de>
Content-Disposition: inline
In-Reply-To: <200410162323.01006.jkillius@arcor.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jan Killius <jkillius@arcor.de> :
> On Saturday 16 October 2004 23:04, Jan Killius wrote:
> > > - what is the current transfer rate and is it better/worse w/o TSO ?
> >
> > I'm getting almost the same with both settings ~405Mbit/s.

Roughly the same CPU usage ?

> >
> > > - which cpu/disk system are there within the (?) 128Mo box ?
> >
> > Athlon XP 1600+ the disk is a Maxtor 6Y060L0 gets with hdparm 42.76 MB/s
> ups forget to say the ram size 512MB FSB333 DDR RAM

I did not notice it first but the bi/bo columns of the vmstat output
are mostly null. Assuming this is a single session ftp transfer, what ftp
software does the r8169 based system run ?

Pure curiosity: can you issue a test+vmstat with a blowfish scp to see if
TSO makes a difference for your setup when the system is not disk-limited ?

--
Ueimor
