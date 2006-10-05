From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH][RFC] net/ipv6: seperate sit driver to extra module
Date: Thu, 5 Oct 2006 11:49:38 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610051148230.23631@d.namei>
References: <20061005154152.GA2102@zlug.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751572AbWJEPtl@vger.kernel.org>
To: Joerg Roedel <joro-lkml@zlug.org>
In-Reply-To: <20061005154152.GA2102@zlug.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 5 Oct 2006, Joerg Roedel wrote:

> Is there a reason why the tunnel driver for IPv6-in-IPv4 is currently
> compiled into the ipv6 module? This driver is only needed in gateways
> between different IPv6 networks. On all other hosts with ipv6 enabled it
> is not required. To have this driver in a seperate module will save
> memory on those machines.
> I appended a small and trival patch to 2.6.18 which does exactly this.

Looks ok to me, although given that users used to get this by default when 
selecting IPv6, perhaps the default in Kconfig should be y.



- James
-- 
James Morris
<jmorris@namei.org>
