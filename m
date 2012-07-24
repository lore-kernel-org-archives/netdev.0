From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 10/17] Tools: hv: Gather ipv[4,6] gateway information
Date: Tue, 24 Jul 2012 09:56:59 -0700
Message-ID: <20120724095659.5c869511@nehalam.linuxnetplumber.net>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
	<1343145701-3691-1-git-send-email-kys@microsoft.com>
	<1343145701-3691-10-git-send-email-kys@microsoft.com>
	<20120724092914.60f3d90a@nehalam.linuxnetplumber.net>
	<20120724165359.GA8409@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "K. Y. Srinivasan" <kys@microsoft.com>, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	virtualization@lists.osdl.org, apw@canonical.com,
	netdev@vger.kernel.org, ben@decadent.org.uk
To: Olaf Hering <olaf@aepfle.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120724165359.GA8409@aepfle.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Jul 2012 18:53:59 +0200
Olaf Hering <olaf@aepfle.de> wrote:

> On Tue, Jul 24, Stephen Hemminger wrote:
> 
> > On Tue, 24 Jul 2012 09:01:34 -0700
> > "K. Y. Srinivasan" <kys@microsoft.com> wrote:
> > 
> > > +	memset(cmd, 0, sizeof(cmd));
> > > +	strcat(cmd, "/sbin/ip -f inet  route | grep -w ");
> > > +	strcat(cmd, if_name);
> > > +	strcat(cmd, " | awk '/default/ {print $3 }'");
> > 
> > 
> > Much simpler method:
> > 
> > ip route show match 0/0
> 
> This also has the benefit that ip is not called with absolute path, now
> that distros move binaries around.
> 
> Olaf

It is also not hard to do the same thing with a little function
using libmnl
