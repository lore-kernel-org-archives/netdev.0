From: Ben Greear <greearb@candelatech.com>
Subject: Re: Function to determine if IP exists on a net-device?
Date: Wed, 19 Nov 2003 18:05:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBC215B.2090100@candelatech.com>
References: <3FBB36F2.7030402@candelatech.com> <20031119173103.1938bc51.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031119173103.1938bc51.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Wed, 19 Nov 2003 01:25:06 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Is there a method already written that will tell me if an IP exists on
>>a netdevice?
>>
>>If not, I am quite sure the answer lies in the in_ifaddr
>>list, but which field holds the IP address for the device?
> 
> 
> Call getifaddrs(), walk the list finding the each and every list entry
> with the 'ifa_name' name matching the device you want.  If there are
> multiple addresses attached to an interface there will be multiple
> in_ifaddr list entries with the 'ifa_name' of your interface.
> 
> In each of those entry, check the sockaddr pointed to by the 'ifa_addr'
> field.


Is there not a more direct access if I already have the netdevice in question?
ie, can I get at the list by looking at dev->ip_ptr struct?


Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
