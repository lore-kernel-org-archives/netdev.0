From: Mark Trompell <mark@foresightlinux.org>
Subject: Re: bridge not getting ip since 3.11.5 and 3.4.66
Date: Tue, 12 Nov 2013 11:57:56 +0100
Message-ID: <CAEPa5ym0+-_Q9zUidDfE2SD7XYZxAqqEUByBkkH1ZOmh9rmFHg@mail.gmail.com>
References: <CAEPa5ym2Xz3F19fJJqNawkRLOKk6Ao6oXrzSrHU051V7p=9otA@mail.gmail.com>
	<CAE3RKNng9A6Bp7wa4+6iCprwEQpzGueagLc8iob+aFabJW4nnw@mail.gmail.com>
	<CAEPa5y=tgdGpDMBGY0ijyWSgQ0m5SZW8EMP072OF=sZZUjqN1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <veaceslav@falico.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEPa5y=tgdGpDMBGY0ijyWSgQ0m5SZW8EMP072OF=sZZUjqN1g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 11, 2013 at 1:52 PM, Mark Trompell <mark@foresightlinux.org> wrote:
> On Mon, Nov 11, 2013 at 12:07 PM, Veaceslav Falico <veaceslav@falico.eu> wrote:
>> On Mon, Nov 11, 2013 at 11:29 AM, Mark Trompell <mark@foresightlinux.org> wrote:
>>> my bridge br0 doesn't get an ip from dhcp anymore after 3.11.5 and 3.4.66,
>>> What information would be helpful and required to find out what's going wrong.
>>
>> CC netdev
>>
>> First thing would be to provide the network scheme. Do you use vlans?
>> Which network
>> cards/drivers are you using? Do you use some kind of virtualization?
>> Is bonding involved?
>>
> Actually this is my desktop machine using kvm for a virtual machine
> that uses eth0 which is connected to the bridge
> which is used as interface for the host.
>
> $ ip addr
> 2. eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast
> master br0 qlen 1000
> ...
> 3. br0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc noqueue
> ...
>
> Anything else?

Okay more about my hardware and configuration:
from lspci:
00:19.0 Ethernet controller: Intel Corporation 82579V Gigabit Network
Connection (rev 04)

/etc/sysconfig/network-scripts/ifcfg-br0
DEVICE=br0
ONBOOT=yes
MACADDR=00:19:99:ac:b3:24
TYPE=Bridge
BOOTPROTO=dhcp
STP=on
NM_CONTROLLED=no
DELAY=0

/etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
HWADDR=00:19:99:cd:a5:e6
#BOOTPROTO=dhcp
ONBOOT=yes
BRIDGE=br0
TYPE=Ethernet
NM_CONTROLLED=no


> Greetings
> Mark
