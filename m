From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.9-rc1-bk11+ and 2.6.9-rc1-mm3,4 r8169: freeze during boot (FIX included)
Date: Tue, 14 Sep 2004 00:02:09 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040913220209.GA13175@electric-eye.fr.zoreil.com>
References: <200409130035.50823.hfvogt@arcor.de> <20040912232604.GC27282@electric-eye.fr.zoreil.com> <200409131443.34374.hfvogt@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268992AbUIMWDX@vger.kernel.org>
To: Hans-Frieder Vogt <hfvogt@arcor.de>
Content-Disposition: inline
In-Reply-To: <200409131443.34374.hfvogt@arcor.de>
List-Id: netdev.vger.kernel.org

Hans-Frieder Vogt <hfvogt@arcor.de> :
[...]
> no oops (BUG_ON not triggered)! System boots up as normal, but just after I 

...

> log in on the console the system freezes, i.e., keyboard does not react any 
> more and the system is not accessible via network.

- do the keyboard leds or the magic sysrq answer (I assume you boot without X) ?
- does it make a difference if you boot with the network cable unpluged (i.e.
  fine until pluged then dead when first packet comes in) ?

> The time from the moment I log in to the time when the system freezes varies, 
> but is in the order of 5s.

First packet probably. Can you verify this point ?

> There is no difference whether NAPI is enabled or not.

I will welcome lspci -vx + gcc version + objdump -S of the r8169 module.

--
Ueimor
