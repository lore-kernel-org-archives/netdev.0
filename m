From: Amador Pahim <amador@pahim.org>
Subject: Re: Find vlanid with non-root user
Date: Wed, 14 Aug 2013 08:43:59 -0300
Message-ID: <CAEFY+qyRyzmwgGan9MBzEwgWYkUPXMrS6PXiENH6js4XHrkweg@mail.gmail.com>
References: <CAEFY+qzCQqEpLjjM1iBjtHmDh70ktpx+GCHgTuCceu1A53-1Tw@mail.gmail.com>
 <20130813144657.361b31b5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:39312 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759573Ab3HNLoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 07:44:21 -0400
Received: by mail-la0-f53.google.com with SMTP id el20so6676424lab.40
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 04:44:20 -0700 (PDT)
In-Reply-To: <20130813144657.361b31b5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you Stephen.

And about to find vlans? Is the same "ip -d link show" the best way?
If yes, any concern in finding interfaces with "@":

# ip -d link show | egrep ":.*@.*:" | cut -d ":" -f 2
 eth1.10-fcoe@eth1
 new_vlan@eth1
 eth1.new_vlan@eth1
 new_vlan2@eth1

For now I am using /sys/class/net/*.*, but as you said before, vlan
can be made with any name.

Best.

On Tue, Aug 13, 2013 at 6:46 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Tue, 13 Aug 2013 17:46:45 -0300
> Amador Pahim <amador@pahim.org> wrote:
>
>> Hello,
>>
>> Is there a way to get vlanid from a vlan interface as a regular user?
>> Default permissions to /proc/net/vlan/ is 600.
>> -rw-------. 1 root root 0 Aug 13 17:23 /proc/net/vlan/eth1.10-fcoe
>
> ip command will work as non-root user and show vlan (with -d)
>
> $ ip -d li show dev eth0vlan
> 13: eth0vlan@eth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT
>     link/ether 10:bf:48:84:6f:5a brd ff:ff:ff:ff:ff:ff
>     vlan id 10 <REORDER_HDR>
>
>
>
>> Not sure if deducting vlanid from vlan name is a reasonable way to do so.
>
> No. Vlan can be made with any name.
>
> # ip li add link eth0 name eth0vlan type vlan id 10
>
>> Thank you in advance,.
>>
>> Best Regards,
>



-- 
Pahim
