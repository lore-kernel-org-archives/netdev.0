From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: More 2.4.22pre10 ACPI breakage
Date: Tue, 05 Aug 2003 22:58:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F306EC4.1030109@pobox.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E01022292CD@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Samuel Flory <sflory@rackable.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E01022292CD@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Feldman, Scott wrote:
>>  It appears that the intel Se7501BR mother is also having 
>>issues with ACPI.  When ACPI support is enable the e1000
>>controller stops working printing "<6>NETDEV WATCHDOG:
>>eth0: transmit timed out".
> 
> 
> Must...have...interrupts.

You are 100% correct.

That said... I'm tempted to extend NAPI just a bit, to provide an 
"always poll" mode.  It seems like all the bug reports I get these days 
for 8139too are caused by x86 ACPI/APIC/irq routing troubles completely 
unrelated to the driver.  Tulip-almost-NAPI in 2.4 has an always-poll 
mode, so I have a convenient excuse :)

	Jeff
