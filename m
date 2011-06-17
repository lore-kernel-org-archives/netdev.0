From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [AX25] inconsistent lock state
Date: Fri, 17 Jun 2011 14:51:48 +0100
Message-ID: <20110617135147.GA3470@linux-mips.org>
References: <4B2CD772.1030106@upmc.fr>
 <20100115203654.GA3084@del.dom.local>
 <4DFA662D.5030302@free.fr>
 <201106171536.15660.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f6bvp <f6bvp@free.fr>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201106171536.15660.arnd@arndb.de>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 17, 2011 at 03:36:15PM +0200, Arnd Bergmann wrote:

(Removed Jarek from cc; his email bounces.)

> The message hints that disc_data_lock is aquired with softirqs disabled,
> but does not itself disable softirqs, which can in rare circumstances
> lead to a deadlock.
> 
> Does this fix it?

If so, drivers/net/hamradio.c, function sp_get() would probably need the
equivalent fix.  Same for drivers/net/ppp_async.c:ap_get() and sp_get() in
drivers/net/ppp_synctty.c.

  Ralf
