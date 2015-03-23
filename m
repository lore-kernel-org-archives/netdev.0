From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH -next] netfilter: Use LOGLEVEL_<FOO> defines
Date: Mon, 23 Mar 2015 14:52:35 +0100
Message-ID: <20150323135235.GA7595@salvia>
References: <20150323140841.0b807b95@canb.auug.org.au>
 <20150323124723.GA6740@salvia>
 <1427115331.16851.11.camel@perches.com>
 <20150323130638.GA6857@salvia>
 <1427117031.16851.16.camel@perches.com>
 <20150324003828.0eac53d9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150324003828.0eac53d9@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 24, 2015 at 12:38:28AM +1100, Stephen Rothwell wrote:
> Hi Joe,
> 
> On Mon, 23 Mar 2015 06:23:51 -0700 Joe Perches <joe@perches.com> wrote:
> >
> > Use the #defines where appropriate.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> > ---
> > > > Perhaps all the .level = 4 uses should be LOGLEVEL_WARNING
> > > > and .level = 5 should be LOGLEVEL_NOTICE
> > > 
> > > Yes, we can push a follow up patch to net-next changing all these
> > > spots in the netfilter tree. Would you send a patch for this?
> > 
> > There are indirect includes of kern_levels.h but there are a
> > lot of indirect includes of kernel.h in netfilter
> 
> I am not sure what you are getting at here.  kernel.h does not include
> kern_levels.h (but printk.h does).  I, for one, am always happier when
> necessary include files are explicitly included.

I would also prefer if you include the explicit header files in that
patch too. Could you send us a v2? Please, Cc:
netfilter-devel@vger.kernel.org

Thanks.
