From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Extend netlink error codes
Date: Mon, 13 Sep 2004 08:26:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913062613.GA12185@wotan.suse.de>
References: <20040910225158.GO20088@postel.suug.ch> <20040911155839.GN4431@wotan.suse.de> <20040911162433.GC21181@postel.suug.ch> <20040912163744.52f95367.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040912163744.52f95367.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Sep 12, 2004 at 04:37:44PM -0700, David S. Miller wrote:
> On Sat, 11 Sep 2004 18:24:33 +0200
> Thomas Graf <tgraf@suug.ch> wrote:
> 
> > > I don't think an very specific error like
> > > "CFQ subsystem parameter X is FOO, can be only upto BAR" 
> > > can be nicely put into a global error file.
> > 
> > True, I would really like to have such error messages.
> 
> I'd love to have them too.
> 
> But I know internationalization folks are going to
> scream, although it will obviously be better than
> no messages at all.

I actually don't think it will be a big issue for them.
They already translate messages by mapping text to other
text. The same thing could be done for kernel messages,
by just marking them in the kernel somehow that they
can be automatically extracted from the source and then 
later mapping them to the translations in user space. 

But I wouldn't do it until someone actually complains
about it.

-Andi
