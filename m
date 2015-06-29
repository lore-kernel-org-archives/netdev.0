From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] printk: implement support for extended console
 drivers
Date: Mon, 29 Jun 2015 11:28:05 -0400
Message-ID: <20150629152805.GM15805@mtj.duckdns.org>
References: <1430318704-32374-1-git-send-email-tj@kernel.org>
 <1430318704-32374-4-git-send-email-tj@kernel.org>
 <CAMuHMdWwH-3kx1ma5KE=fP94by8boxM_QYqPKpU=YJw8t3hYeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pmladek@suse.cz, Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kay Sievers <kay@vrfy.org>,
	Josh Triplett <josh@joshtriplett.org>,
	Linux Embedded <linux-embedded@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-embedded-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdWwH-3kx1ma5KE=fP94by8boxM_QYqPKpU=YJw8t3hYeg@mail.gmail.com>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Mon, Jun 29, 2015 at 11:20:41AM +0200, Geert Uytterhoeven wrote:
> On Wed, Apr 29, 2015 at 4:45 PM, Tejun Heo <tj@kernel.org> wrote:
> > --- a/kernel/printk/printk.c
> > +++ b/kernel/printk/printk.c
> 
> > @@ -2196,6 +2227,7 @@ out:
> >   */
> >  void console_unlock(void)
> >  {
> > +       static char ext_text[CONSOLE_EXT_LOG_MAX];
> 
> Can you please
>   a) make this feature optional,

netconsole itself is optional & modular.  I'm not sure making further
splits is called for, especially given the use cases.

>   b) (de)allocate this buffer dynamically when the first/last console with
>       CON_EXTENDED set is (un)registered?

But yeah, making the buffer allocated on demand should be simple
enough.  Will get to it.

Thanks.

-- 
tejun
