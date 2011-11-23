From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/2] ax25: integer overflows in ax25_setsockopt()
Date: Wed, 23 Nov 2011 14:39:13 +0000
Message-ID: <20111123143913.50fbcc8c@lxorguk.ukuu.org.uk>
References: <7187C142-99F1-4A96-9BE6-650B10C9B22D@gmail.com>
	<20111123104449.5e845a0f@lxorguk.ukuu.org.uk>
	<CAKU6vyY3WjVwTK5Tcp2W93DefjJMreZjhtudNHBALns=6bK9Jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Joerg Reuter <jreuter@yaina.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <CAKU6vyY3WjVwTK5Tcp2W93DefjJMreZjhtudNHBALns=6bK9Jw@mail.gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Nov 2011 09:04:11 -0500
Xi Wang <xi.wang@gmail.com> wrote:

> All these magic numbers come from net/ax25/sysctl_net_ax25.c, where
> min/max values of each field are set for sysctl.  Is it okay to use
> them?

The sysctl range is the 'standard' range, but it's always historically
been possible to override them in apps for special cases. I'm wary of
changing that because people do insane things like AX.25 bounced off the
moon where you need very long timeouts.

Alan
