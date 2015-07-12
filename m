From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: dsa: mv88e6xxx: add write access to debugfs
 regs file
Date: Sat, 11 Jul 2015 19:08:22 -0700 (PDT)
Message-ID: <20150711.190822.1431177169987395247.davem@davemloft.net>
References: <1436476409-5033-1-git-send-email-vivien.didelot@savoirfairelinux.com>
	<20150710.230120.1590955832899872718.davem@davemloft.net>
	<1092744390.7730.1436639772848.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@roeck-us.net, andrew@lunn.ch,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1092744390.7730.1436639772848.JavaMail.zimbra@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Sat, 11 Jul 2015 14:36:12 -0400 (EDT)

> In the meantime, this is really useful for development. i.e. ensuring a good
> switchdev/DSA interaction without being able to read and write directly the
> hardware VLAN table, is a bit a PITA. A dynamic debugfs looked appropriate.

For "development" you can hack the driver, add tracepoints, or use
another mechanism anyone hacking the kernel (which by definition
someone doing "development" is doing) can do.

I do not buy any of your arguments, and you really miss the grand
opportunity to export the knobs and values in a way which are going
to:

1) Be useful to users

2) Be usable by any similar DSA driver, not just _yours_

So please stop this myopic narrow thinking when you add facilities for
development or export values.  Think of the big picture and long term,
not just your personal perceived immediate needs of today.

Thanks.
