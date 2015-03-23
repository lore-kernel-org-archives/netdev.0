From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH -next] netfilter: Use LOGLEVEL_<FOO> defines
Date: Mon, 23 Mar 2015 08:36:59 -0700
Message-ID: <1427125019.16851.20.camel@perches.com>
References: <20150323140841.0b807b95@canb.auug.org.au>
	 <20150323124723.GA6740@salvia> <1427115331.16851.11.camel@perches.com>
	 <20150323130638.GA6857@salvia> <1427117031.16851.16.camel@perches.com>
	 <20150324003828.0eac53d9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150324003828.0eac53d9@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-24 at 00:38 +1100, Stephen Rothwell wrote:
> Hi Joe,

Hi Stephen.

> I am not sure what you are getting at here.  kernel.h does not include
> kern_levels.h (but printk.h does).  I, for one, am always happier when
> necessary include files are explicitly included.

kernel.h -> printk.h -> kern_levels.h

No .c file in the tree does a specific #include
of kern_levels.h, only a couple of .S files.

Adding printk.h might be useful, but I think
that kernel.h is probably better.
