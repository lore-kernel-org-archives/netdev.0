From: jamal <hadi@cyberus.ca>
Subject: Re: Getting details about an 802.1q VLAN interface from userspace
Date: Tue, 18 Feb 2003 21:48:34 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030218214714.J25195@shell.cyberus.ca>
References: <20030213143921.A21977@cisco.com> <20030217.182915.41644338.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: wjhun@cisco.com, "" <greearb@candelatech.com>, "" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030217.182915.41644338.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I think these should be new attributes to RTM_*LINK.
No need to define a new message.

cheers,
jamal

On Mon, 17 Feb 2003, David S. Miller wrote:

>    From: Will Jhun <wjhun@cisco.com>
>    Date: Thu, 13 Feb 2003 14:39:21 -0800
>
>    Is there a better way to get this information via netlink or some
>    ioctl()? Would it be useful if I (or someone) added an ioctl() type to
>    get information about a VLAN interface? (vlan, ifindex of trunking
>    (real_dev) interface, priority maps; basically the content of struct
>    vlan_dev_info)
>
> I would accept new netlink interfaces to get and set this
> information.  ioctls are gross and will not be tolerated :)
>
>
>
