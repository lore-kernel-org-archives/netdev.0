From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc4 2/3] ns83820: move eeprom.h and clean up
Date: Fri, 15 Oct 2004 19:44:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417060D6.3080100@pobox.com>
References: <20041015154400.11611d9b@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041015154400.11611d9b@zqx3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The file linux/eeprom.h was only being used by the ns83820 driver,
> and it contained non-inline functions in a .h file.  This patch 
> fixes that and:
> 	* Only two functions are actually used (and only used once)
> 	  so ditch the rest and make those inline.
> 	* EEprom is in iomemory space so get rid of the warnings.
> 	
> Compiles but I don't have this hardware, so it has not been tested.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


actually, Ben's idea with linux/eeprom.h was to stop duplicating the 
same eeprom logic in each driver, and centralize it instead.

Did you look at trying to do that?

	Jeff
