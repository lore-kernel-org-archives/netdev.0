From: "David S. Miller" <davem@redhat.com>
Subject: Re: Getting details about an 802.1q VLAN interface from userspace
Date: Mon, 17 Feb 2003 18:29:15 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030217.182915.41644338.davem@redhat.com>
References: <20030213143921.A21977@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: wjhun@cisco.com
In-Reply-To: <20030213143921.A21977@cisco.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Will Jhun <wjhun@cisco.com>
   Date: Thu, 13 Feb 2003 14:39:21 -0800
   
   Is there a better way to get this information via netlink or some
   ioctl()? Would it be useful if I (or someone) added an ioctl() type to
   get information about a VLAN interface? (vlan, ifindex of trunking
   (real_dev) interface, priority maps; basically the content of struct
   vlan_dev_info)

I would accept new netlink interfaces to get and set this
information.  ioctls are gross and will not be tolerated :)
