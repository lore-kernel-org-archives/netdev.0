From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: multiple unicast mac address (was Re: netdev_ops retraction)
Date: Thu, 31 Jul 2003 10:44:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F292B38.4070508@pobox.com>
References: <20030730184416.GI22222@parcelfarce.linux.theplanet.co.uk> <2147483647.1059659359@fozzy.rossfell.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Payne <rickp@rossfell.co.uk>
In-Reply-To: <2147483647.1059659359@fozzy.rossfell.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Payne wrote:
> 
> --On Wednesday, July 30, 2003 7:44 pm +0100 Matthew Wilcox 
> <willy@debian.org> wrote:
> 
>> +       void    (*set_multicast_list)(struct net_device *dev);
>> +       int     (*set_mac_address)(struct net_device *dev, void *addr);
> 
> 
> Talking of which - is there any appetite for a patch that allows 
> multiple unicast mac addresses to be set on an ethernet interface? Its 
> certainly much neater for things like VRRP and HA stuff if an ethernet 
> device is able to continue accepting packets for its original MAC 
> address, as well as the 'virtual MAC address'.
> 
> Obviously I'm not talking about generated packets (they will still take 
> the MAC address from dev->dev_addr) - I'm talking about the hardware 
> filter on the ethernet cards themselves. (In some cases, the software 
> concerned may want to set_mac_address - thus updating dev->dev_addr, and 
> then also add the original mac address to the 'unicast accept list' for 
> instance).


This feature request comes up about once a year.  Search the archives 
for responses...

Hardware that filters N MAC addresses (unicast filtering) doesn't have a 
terribly standard interface, and the unicast filter must be adjusted at 
different times on different hardware.  Also, chip bugs lead one to 
think unicast filtering will work where it doesn't.  Also, chip limits 
for some of the more popular chips are unknown.  Also, the need for this 
feature is very uncommon, and can be achieved in other ways.

	Jeff
