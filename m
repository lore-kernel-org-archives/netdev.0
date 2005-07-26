From: Matt Mackall <mpm@selenic.com>
Subject: Re: [2.6 patch] NETCONSOLE must depend on INET
Date: Tue, 26 Jul 2005 16:58:24 -0700
Message-ID: <20050726235824.GN12006@waste.org>
References: <20050719182919.GA5531@stusta.de> <20050719.140104.68160812.davem@davemloft.net> <20050726232043.GB7425@waste.org> <20050726.163202.119887768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bunk@stusta.de, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262423AbVG0ABW@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050726.163202.119887768.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 26, 2005 at 04:32:02PM -0700, David S. Miller wrote:
> From: Matt Mackall <mpm@selenic.com>
> Date: Tue, 26 Jul 2005 16:20:43 -0700
> 
> > This problem also exists in PKTGEN. And this fix is incorrect as
> > neither is dependent on the IP part of the networking stack in any
> > substantive way. The right fix is to make inet_aton available outside
> > of CONFIG_INET (preferred) or making private copies of inet_aton.
> 
> Adrian posted a fix, you whine, that's why Adrian's fix
> went in :-)

Adrian's fix is the moral equivalent of throwing in a cast to shut up
a compiler warning for a legitimate bug.
 
> More seriously, please submit a version of whatever you
> believe to be the more correct fix so it can be reviewed
> and integrated.

Do you have a preferred location to put this function or
shall I invent one?

-- 
Mathematics is the supreme nostalgia of our time.
