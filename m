From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 3/3] drivers/net/wireless/prism54/*: convert to pci_register_driver
Date: Mon, 07 Mar 2005 12:23:40 -0500
Message-ID: <422C8E1C.40400@pobox.com>
References: <20050306222358.752961EC90@trashy.coderock.org> <20050307171444.GU3936@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: domen@coderock.org, prism54-private@prism54.org, netdev@oss.sgi.com,
        c.lucas@ifrance.com
To: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
In-Reply-To: <20050307171444.GU3936@ruslug.rutgers.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez wrote:
> On Sun, Mar 06, 2005 at 11:23:58PM +0100, domen@coderock.org wrote:
> 
>>convert from pci_module_init to pci_register_driver
>>(from:http://kerneljanitors.org/TODO).
>>
>>Signed-off-by: Christophe Lucas <c.lucas@ifrance.com>
>>Signed-off-by: Domen Puncer <domen@coderock.org>
>>---
>>
>>
>> kj-domen/drivers/net/wireless/prism54/islpci_hotplug.c |    2 +-
>> 1 files changed, 1 insertion(+), 1 deletion(-)
>>
>>diff -puN drivers/net/wireless/prism54/islpci_hotplug.c~pci_register_driver-drivers_net_wireless_prism54 drivers/net/wireless/prism54/islpci_hotplug.c
>>--- kj/drivers/net/wireless/prism54/islpci_hotplug.c~pci_register_driver-drivers_net_wireless_prism54	2005-03-05 16:12:44.000000000 +0100
>>+++ kj-domen/drivers/net/wireless/prism54/islpci_hotplug.c	2005-03-05 16:12:44.000000000 +0100
>>@@ -315,7 +315,7 @@ prism54_module_init(void)
>> 
>> 	__bug_on_wrong_struct_sizes ();
>> 
>>-	return pci_module_init(&prism54_driver);
>>+	return pci_register_driver(&prism54_driver);
>> }
>> 
>> /* by the time prism54_module_exit() terminates, as a postcondition
>>_
> 
> 
> How about this one? Is this 2.4 compat?

Nope, not 2.4 compatible.

	Jeff
