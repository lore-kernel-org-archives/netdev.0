From: Pekka Savola <pekkas@netcore.fi>
Subject: disablenetwork() syscall?
Date: Mon, 7 Jul 2003 22:40:02 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307072237560.11843-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

In a bugtraq thread, DJ Bernstein brought up an idea which I'm not sure 
has been brought up in the past.  I'm not sure whether it's feasible or 
not, but at least it (and other methods to limit the functions of a 
user-level code) might bear consideration.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
---------- Forwarded message ----------
Date: 4 Jul 2003 23:17:20 -0000
From: D. J. Bernstein <djb@cr.yp.to>
To: bugtraq@securityfocus.com
Subject: Re: Email marketing company gives out questionable security advice

[...]
P.S. It's hard for a portable chroot tool to cut off a program's network
access. Kernel designers should provide a disablenetwork() syscall, with
the disabling inherited by children. Other kernel changes would be nice,
but disablenetwork() is the only critical change.
