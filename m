From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 0/7] 2.6.6-rc3-mm1 - description of the r8169 queue
Date: Sun, 2 May 2004 22:51:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040502225117.A24214@electric-eye.fr.zoreil.com>
References: <20040501022308.A32762@electric-eye.fr.zoreil.com> <40954DE9.3020209@myrealbox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, Jon D Mason <jonmason@us.ibm.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Lutomirski <luto@myrealbox.com>
Content-Disposition: inline
In-Reply-To: <40954DE9.3020209@myrealbox.com>; from luto@myrealbox.com on Sun, May 02, 2004 at 12:37:13PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andy Lutomirski <luto@myrealbox.com> :
[...]
> 3. NAPI is missing from Kconfig

It appears in patch 1/7 but it has not been included in the global patch
which is available online (fixed by now). This part of your patch should
be ignored. The remaining parts are fine.

> These patches also chance the initial chipset reset timer from 2 jiffies 
> to 100ms (for HZ-independence, and 2ms sounds overly short.)

Compared to the initial busy-looping, the 2ms timer did not look _that_
inefficient :o) As the reset is expected to take place in 0.5s at worst,
your change makes more sense.

--
Ueimor
