From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [patch] ipv4: initialize arp_tbl rw lock
Date: Sat, 8 Apr 2006 12:42:44 +0200
Message-ID: <20060408104244.GB9412@osiris.boeblingen.de.ibm.com>
References: <20060407081533.GC11353@osiris.boeblingen.de.ibm.com> <20060407074627.2f525b2e@localhost.localdomain> <20060408100213.GA9412@osiris.boeblingen.de.ibm.com> <20060408.031404.111884281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, jgarzik@pobox.com, akpm@osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fpavlic@de.ibm.com, davem@sunset.davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964888AbWDHKmy@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060408.031404.111884281.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> We could make inet_init() a subsystem init but I vaguely recall
> that we were doing that at one point and it broke things for
> some reason.
> 
> Perhaps fs_initcall() would work better.  Or if that causes
> problems we could create a net_initcall() that sits between
> fs_initcall() and device_initcall().
> 
> Or any other ideas?

Just tried fs_initcall() and net_initcall(). Both seem to have some
side effects:
Symptom is that console output sometimes hangs for several seconds at:
"NET: Registered protocol family 2" while all cpus are in cpu_idle().

Heiko
