From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [next] unix stream crashes
Date: Thu, 01 Sep 2011 18:40:45 -0700
Message-ID: <1314927645.2576.2939.camel@schen9-DESK>
References: <4E5FEF28.60406@gmail.com>
	 <3179.1314924559@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3179.1314924559@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-09-01 at 20:49 -0400, Valdis.Kletnieks@vt.edu wrote:
> On Thu, 01 Sep 2011 22:46:32 +0200, Jiri Slaby said:
> > Hi,
> > 
> > my box 100% crashes when booting. It's both in unix socket recv and send 
> > paths. I've reverted 0856a30409 (Scm: Remove unnecessary pid & 
> > credential references in Unix socket's send and receive path) and it 
> > seems to help.
> > 
> > The oops:
> > http://www.fi.muni.cz/~xslaby/sklad/panics/af_unix_crash.png
> 
> I was seeing a 100% repeatable crash with the X server starting as well, but
> wasn't able to get a traceback because my X server was doing the modeset before
> it crashed (so all I got was a black screen) and netconsole is busticated for
> me.  I can confirm that reverting that one commit allows my box to boot and get
> X up and running as well.
> 

Yes, Jiri's log does indicate that something went wrong when releasing
the skb, most likely due to changes in the pid and credentials ref
count.  Unfortunately, I cannot duplicate the problem on my system.  Any
info on your system to help me debug will be appreciated.  I'll try to
take another look at the patch tomorrow.

Tim
