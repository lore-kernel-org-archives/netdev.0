From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.1-mm4
Date: Sun, 18 Jan 2004 00:17:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040118001708.09291455.akpm@osdl.org>
References: <20040115225948.6b994a48.akpm@osdl.org>
	<20040118001217.GE3125@werewolf.able.es>
	<20040117215535.0e4674b8.akpm@osdl.org>
	<20040118081128.GA3153@werewolf.able.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "J.A. Magallon" <jamagallon@able.es>
In-Reply-To: <20040118081128.GA3153@werewolf.able.es>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"J.A. Magallon" <jamagallon@able.es> wrote:
>
> 
> On 01.18, Andrew Morton wrote:
> > "J.A. Magallon" <jamagallon@able.es> wrote:
> > >
> > > On 01.16, Andrew Morton wrote:
> > >  > 
> > >  > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1/2.6.1-mm4/
> > >  > 
> > >  > 
> > > 
> > >  Net driver problem:
> > > 
> > >  werewolf:/etc# modprobe --verbose 3c59x
> > >  insmod /lib/modules/2.6.1-jam4/kernel/drivers/net/3c59x.ko 
> > >  FATAL: Error inserting 3c59x (/lib/modules/2.6.1-jam4/kernel/drivers/net/3c59x.ko): Invalid argument
> > 
> > hmm, cute.
> > 
> 
> Yes.
> It worked. 
> I thought of this, but why this and not the other parameters ? Compiler bug ?

Presumably, recent gcc's remove the variable altogether and just expand the
constant inline.  When the central module code checks for the parameter's
existence in the module's symbol table it errors out.
