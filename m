From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [patch] ipv4: initialize arp_tbl rw lock
Date: Sat, 8 Apr 2006 14:14:54 +0200
Message-ID: <20060408121454.GA16761@mars.ravnborg.org>
References: <20060407081533.GC11353@osiris.boeblingen.de.ibm.com> <20060407074627.2f525b2e@localhost.localdomain> <20060408100213.GA9412@osiris.boeblingen.de.ibm.com> <20060408.031404.111884281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: heiko.carstens@de.ibm.com, shemminger@osdl.org, jgarzik@pobox.com,
	akpm@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fpavlic@de.ibm.com,
	davem@sunset.davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964841AbWDHMP3@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060408.031404.111884281.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 08, 2006 at 03:14:04AM -0700, David S. Miller wrote:
 
> Perhaps fs_initcall() would work better.  Or if that causes
> problems we could create a net_initcall() that sits between
> fs_initcall() and device_initcall().

fs_initcall() seems to be used mainly for "init after subsystem" stuff.
Within fs/ only pipe.c uses fs_initcall().

If we are going to overload the usage of fs_initcall() even more then
we should maybe try to rename it?


	Sam
