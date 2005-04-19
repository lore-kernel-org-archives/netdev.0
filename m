From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [2.6 patch] kill include/linux/eeprom.h
Date: Tue, 19 Apr 2005 09:56:48 -0400
Message-ID: <20050419135648.GC7315@kvack.org>
References: <20050419012935.GQ5489@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20050419012935.GQ5489@stusta.de>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At the very least your patch doesn't do a thorough enough job of 
removing the dead code -- there is no good reason to move the unused 
code into ns83820.c.

Also, someone needs to go around refactoring eeprom code out of the 
network drivers at some point.

		-ben
