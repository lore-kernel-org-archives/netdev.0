From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/1] More ethtool support for sis900
Date: Sun, 6 Mar 2005 01:15:46 +0100
Message-ID: <20050306001546.GE25116@electric-eye.fr.zoreil.com>
References: <20050305134011.23638.68926@localhost.localdomain> <4229FA32.4000401@pobox.com> <02a49476862ae18433e5b80aafa616fd@libero.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
To: Daniele Venzano <webvenza@libero.it>
Content-Disposition: inline
In-Reply-To: <02a49476862ae18433e5b80aafa616fd@libero.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Daniele Venzano <webvenza@libero.it> :
[...]
> I saw the locking, but I couldn't come up with a reason for it. Is it 
> needed because of kernel wide preemption ?

Usually you do not want simultaneous accesses to the mii interface
(link events, Tx timeout recovery or so).

>From a quick glance at the sis900 driver, I would expect the lock to
protect against sis900_timer() (assuming you add a simple spinlock to
it as well).

--
Ueimor
