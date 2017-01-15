From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 00/10] net: dsa: Support for pdata in dsa2
Date: Sun, 15 Jan 2017 09:40:24 -0800
Message-ID: <bc0d9ea7-17ee-abc3-b2aa-4d241413b9a3@gmail.com>
References: <20170114214713.28109-1-f.fainelli@gmail.com>
 <20170115110831.GH26374@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        "moderated list:ARM SUB-ARCHITECTURES"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170115110831.GH26374@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/15/2017 03:08 AM, Greg KH wrote:
> On Sat, Jan 14, 2017 at 01:47:03PM -0800, Florian Fainelli wrote:
>> Hi all,
>>
>> This is not exactly new, and was sent before, although back then, I did not
>> have an user of the pre-declared MDIO board information, but now we do. Note
>> that I have additional changes queued up to have b53 register platform data for
>> MIPS bcm47xx and bcm63xx.
>>
>> Yes I know that we should have the Orion platforms eventually be converted to
>> Device Tree, but until that happens, I don't want any remaining users of the
>> old "dsa" platform device (hence the previous DTS submissions for ARM/mvebu)
>> and, there will be platforms out there that most likely won't never see DT
>> coming their way (BCM47xx is almost 100% sure, BCM63xx maybe not in a distant
>> future).
>>
>> We would probably want the whole series to be merged via David Miller's tree
>> to simplify things.
>>
>> Greg, can you Ack/Nack patch 5 since it touched the core LDD?
> 
> I've NAKed them for now, you need to describe what you are trying to do
> here, as it doesn't make any sense to me at the moment.

For one, this is moving *existing* code from net/dsa/dsa.c part into the
device core for device_find_class() and part into the network device
core for dev_to_net_device(). Patch 8 is where this actually gets used.
See my individual replies for more details.

Even though the existing code is there in net/dsa/dsa.c, at this point,
and for the sake of getting these patches merged via David, I can
probably just keep it where it is (like what patch series v1 did) and
just namespace it with dsa_. Later on, if this is deemed valuable to
other parts of the kernel, I can try to relocate it to the device core,
does that sound acceptable?
-- 
Florian
