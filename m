From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] kill include/linux/eeprom.h
Date: Wed, 20 Apr 2005 01:56:46 +0200
Message-ID: <20050419235646.GY5489@stusta.de>
References: <20050419012935.GQ5489@stusta.de> <20050419135648.GC7315@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Content-Disposition: inline
In-Reply-To: <20050419135648.GC7315@kvack.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 19, 2005 at 09:56:48AM -0400, Benjamin LaHaise wrote:

> At the very least your patch doesn't do a thorough enough job of 
> removing the dead code -- there is no good reason to move the unused 
> code into ns83820.c.

Where does my patch do this?
Only the one actually used function setup_ee_mem_bitbanger is moved to
ns83820.c .

> Also, someone needs to go around refactoring eeprom code out of the 
> network drivers at some point.

I have no problem with this, but it has to be done right.

> 		-ben

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

