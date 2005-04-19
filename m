From: Nick Winlund <nwinlu@comcast.net>
Subject: Re: [2.6 patch] kill include/linux/eeprom.h
Date: Tue, 19 Apr 2005 07:09:38 -0700
Message-ID: <42651122.30906@comcast.net>
References: <20050419012935.GQ5489@stusta.de> <20050419135648.GC7315@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, jgarzik@pobox.com,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>
In-Reply-To: <20050419135648.GC7315@kvack.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No I think the eeprom routine should be saved as it is now for niche 
vendors and hobbyists. At the very least an accessible versions 
repository or CVS containing all prior versions of eeprom implementation 
should be available, a la a new " bitkeeper " or whatever retrieval 
interface Linus and collaborators decide on.

One project where linux+eeprom may be used: 
http://www.ethernut.de/api/if__var_8h.html

Nut OS API

int 	NutNetLoadConfig (CONST char *name)
  	Load network configuration from EEPROM.
int 	NutNetSaveConfig (void)
  	Save network configuration in EEPROM.

Nick

Benjamin LaHaise wrote:
> At the very least your patch doesn't do a thorough enough job of 
> removing the dead code -- there is no good reason to move the unused 
> code into ns83820.c.
> 
> Also, someone needs to go around refactoring eeprom code out of the 
> network drivers at some point.
> 
> 		-ben
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

