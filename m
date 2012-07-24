From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH 10/17] Tools: hv: Gather ipv[4,6] gateway information
Date: Tue, 24 Jul 2012 18:53:59 +0200
Message-ID: <20120724165359.GA8409@aepfle.de>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-10-git-send-email-kys@microsoft.com>
 <20120724092914.60f3d90a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "K. Y. Srinivasan" <kys@microsoft.com>, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	virtualization@lists.osdl.org, apw@canonical.com,
	netdev@vger.kernel.org, ben@decadent.org.uk
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120724092914.60f3d90a@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24, Stephen Hemminger wrote:

> On Tue, 24 Jul 2012 09:01:34 -0700
> "K. Y. Srinivasan" <kys@microsoft.com> wrote:
> 
> > +	memset(cmd, 0, sizeof(cmd));
> > +	strcat(cmd, "/sbin/ip -f inet  route | grep -w ");
> > +	strcat(cmd, if_name);
> > +	strcat(cmd, " | awk '/default/ {print $3 }'");
> 
> 
> Much simpler method:
> 
> ip route show match 0/0

This also has the benefit that ip is not called with absolute path, now
that distros move binaries around.

Olaf
