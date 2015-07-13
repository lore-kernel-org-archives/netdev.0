From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2] net: dsa: mv88e6xxx: add write access to debugfs
 regs file
Date: Sun, 12 Jul 2015 21:39:30 -0400 (EDT)
Message-ID: <1788707459.58885.1436751570981.JavaMail.zimbra@savoirfairelinux.com>
References: <1436476409-5033-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20150710.230120.1590955832899872718.davem@davemloft.net> <1092744390.7730.1436639772848.JavaMail.zimbra@savoirfairelinux.com> <20150711.190822.1431177169987395247.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>, andrew@lunn.ch,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: David <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150711.190822.1431177169987395247.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Jul 11, 2015, at 10:08 PM, David davem@davemloft.net wrote:

> From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Date: Sat, 11 Jul 2015 14:36:12 -0400 (EDT)
> 
>> In the meantime, this is really useful for development. i.e. ensuring a good
>> switchdev/DSA interaction without being able to read and write directly the
>> hardware VLAN table, is a bit a PITA. A dynamic debugfs looked appropriate.
> 
> For "development" you can hack the driver, add tracepoints, or use
> another mechanism anyone hacking the kernel (which by definition
> someone doing "development" is doing) can do.
> 
> I do not buy any of your arguments, and you really miss the grand
> opportunity to export the knobs and values in a way which are going
> to:
> 
> 1) Be useful to users
> 
> 2) Be usable by any similar DSA driver, not just _yours_

I hardly see how this debug interface can be made generic to other DSA drivers,
since the format of hardware tables or some registers seem very specific to the
switch chip.

> So please stop this myopic narrow thinking when you add facilities for
> development or export values.  Think of the big picture and long term,
> not just your personal perceived immediate needs of today.

I understand. So it looks like the only reasonable solution here is to revert
this support for the debugfs interface.

Thanks,
-v
