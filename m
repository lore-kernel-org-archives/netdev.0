From: folkert <folkert@vanheusden.com>
Subject: Re: CPU: 0 Not tainted  (3.1.9+ #1) when ifconfig rose0 down
Date: Fri, 3 Aug 2012 16:32:00 +0200
Message-ID: <20120803143200.GE10211@belle.intranet.vanheusden.com>
References: <5017E786.5000102@free.fr>
 <87ipd0ykdg.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernard Pidoux <bernard.pidoux@free.fr>,
	linux-hams <linux-hams@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87ipd0ykdg.fsf@xmission.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> You might want to simply try moving unregister_netdevice_notifier a bit
> earlier in rose_exit and see if that helps.  Otherwise I would recommend
> instrumenting the code up with some printk so you can understand what
> part of unregistration is failing.

Or bisect! Give e.g. the oldest 2.6 kernel a try to find a last known
good and then do a bisect upto a known bad kernel.


Folkert van Heusden

-- 
To MultiTail einai ena polymorfiko ergaleio gia ta logfiles kai tin
eksodo twn entolwn. Prosferei: filtrarisma, xrwmatismo, sygxwneysi,
diaforetikes provoles. http://www.vanheusden.com/multitail/
----------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE, www.vanheusden.com
