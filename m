From: Donald Becker <becker@scyld.com>
Subject: Re: Must dev->set_multicast_list() complete before returning?
Date: Tue, 1 Apr 2003 22:50:07 -0500 (EST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0304012242360.1685-100000@beohost.scyld.com>
References: <3e89cbe235cd78.41777977@not right>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net@vger.kernel.org, <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <3e89cbe235cd78.41777977@not right>
List-Id: netdev.vger.kernel.org

On Tue, 1 Apr 2003, Rask Ingemann Lambertsen wrote:

> Must dev->set_multicast_list() complete the configuration of a network
> device before returning? 

The promiscuous setting must complete before return, but there are
several drivers where the updated multicast filter does not immediately
take effect.

I have not seen hardware where setting promiscuous mode is a queued
command.  If you have such hardware, you may have to do some extra
software filtering and accept missing some packets during transitions.

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993

