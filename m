From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH 2.5.70+] tun using alloc_netdev
Date: Wed, 11 Jun 2003 14:03:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20030611140042.0b8b5950@unixmail.qualcomm.com>
References: <20030611194317.GE31051@gtf.org>
 <20030609115857.38bb31d6.shemminger@osdl.org>
 <5.1.0.14.2.20030611121155.0b659e20@unixmail.qualcomm.com>
 <20030611194317.GE31051@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>, Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030611132715.76a485c7.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 01:27 PM 6/11/2003, Stephen Hemminger wrote:
>On Wed, 11 Jun 2003 15:43:18 -0400
>Jeff Garzik <jgarzik@pobox.com> wrote:
>
>> > 
>> > This is wrong. register_netdevice() does not expand name (ie %d stuff).
>> > So dev_alloc_name() is still needed. i.e.
>> 
>> Correct.
>> 
>> But, register_netdev() is preferred precisely for this reason.
>> 
>
>Not possible in this case because device is created off socket ioctl so it is
>called with rtnl_lock
Yep. But not because it's created from socket ioctl. Because it has to guaranty atomicity.

Max
