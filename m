From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v3] netconsole: Add tty driver
Date: Sun, 6 Apr 2014 18:21:00 +0100
Message-ID: <20140406182100.5206758e@alan.etchedpixels.co.uk>
References: <20140402185904.GD11734@NewsNow.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org,
	Andreas Schwab <schwab@linux-m68k.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Pirko <jiri@resnulli.us>, Joe Perches <joe@perches.com>,
	Dan Aloni <alonid@postram.com>
To: Struan Bartlett <struan.bartlett@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140402185904.GD11734@NewsNow.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2 Apr 2014 19:59:04 +0100
Struan Bartlett <struan.bartlett@gmail.com> wrote:

> Adds tty driver to netconsole module. 

NAK

You don't need to add a tty driver to any console to do this. We have a
ttyprintk driver that works with *any* console today.

Alan
