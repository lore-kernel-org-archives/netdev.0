From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 14:04:11 -0800
Message-ID: <424C73DB.2090501@candelatech.com>
References: <424C6089.1080507@candelatech.com>	<20050331130512.7e4b8bc0@dxpl.pdx.osdl.net>	<424C6F82.7030609@candelatech.com> <20050331135229.432afff3.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050331135229.432afff3.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 31 Mar 2005 13:45:38 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>>	Adding new ioctl's are very frowned on
>>
>>Bummer.  I want these as well, makes programatic reading of the information
>>much easier than trying to parse some proc file.  I will look into what it
>>takes to make them compat with 64-bit as DaveM suggested.
> 
> 
> You could extend and use ethtool.  That is what it's there for.

The IOCTLs I need are very specific and will only be used for
the redirect module.  I don't think it would be worth adding
a function pointer to the ethtool-ops, but if that is what you
prefer I can do so.

With regard to the compat:  I did a quick search for 'vlan' in that
file, thinking I'd mimic whatever was done for the .1q module.  There
is no mention of vlan anywhere in there.  Does that mean that so long
as I don't use pointers, strictly define my data types (u32, etc),
and make sure the ioctl structs are padded to 32-bit (or maybe 64-bit?)
boundaries, I don't need any 64-bit compat code?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
