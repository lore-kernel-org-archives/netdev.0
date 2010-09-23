From: Tim Small <tim@seoss.co.uk>
Subject: Re: [PATCH] Use firmware provided index to register a network interface
Date: Thu, 23 Sep 2010 07:34:20 +0100
Message-ID: <4C9AF4EC.7020408@seoss.co.uk>
References: <20100922183137.GA7607@auslistsprd01.us.dell.com>	<4C9A7E39.2020304@buttersideup.com> <20100922151645.649d3d7a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Narendra K <Narendra_K@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-pci@vger.kernel.org,
	matt_domsch@dell.com, charles_rose@dell.com,
	jordan_hargrave@dell.com, vijay_nijhawan@dell.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20100922151645.649d3d7a@nehalam>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
>>> http://marc.info/?l=linux-netdev&m=125510301513312&w=2
>> Out of interest, that link says that doing it in usespace was rejected,
>> but doesn't give any references... I'd be interested to know why this
>> wasn't viable - since this seemed like the best fit at first glance -
>> most people will never use this, so no need to grow their kernel size
>> and complexity?
>>
>>     
>
> This proposal was to ad changes into every application that
> knows about network names (iproute, iptables, snmp, quagga, openswan, ...)
> to do aliasing at the application layer.
>   


OK, that's bonkers, but what I was refering to was the line in the
linked post which said "Achieve the above in userspace only using udev"
- which I assumed meant to do it once in a udev rename rule by adapting
/etc/udev/rules.d/70-persistent-net.rules , /lib/udev/write_net_rules 
etc. - which is what I've used to enforce this sort of convention myself
from time to time.

Tim.

-- 
South East Open Source Solutions Limited
Registered in England and Wales with company number 06134732.  
Registered Office: 2 Powell Gardens, Redhill, Surrey, RH1 1TQ
VAT number: 900 6633 53  http://seoss.co.uk/ +44-(0)1273-808309
