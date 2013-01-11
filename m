From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.8-rc] tuntap: refuse to re-attach to different
 tun_struct
Date: Thu, 10 Jan 2013 21:12:37 -0800 (PST)
Message-ID: <20130110.211237.653335807366477404.davem@davemloft.net>
References: <1357804788-19976-1-git-send-email-stefanha@redhat.com>
	<20130110.143902.2166041015759450388.davem@davemloft.net>
	<50EF6AF0.1020005@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefanha@redhat.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50EF6AF0.1020005@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 11 Jan 2013 09:29:20 +0800

> On 01/11/2013 06:39 AM, David Miller wrote:
>> From: Stefan Hajnoczi <stefanha@redhat.com>
>> Date: Thu, 10 Jan 2013 08:59:48 +0100
>>
>>> Multiqueue tun devices support detaching a tun_file from its tun_struct
>>> and re-attaching at a later point in time.  This allows users to disable
>>> a specific queue temporarily.
>>>
>>> ioctl(TUNSETIFF) allows the user to specify the network interface to
>>> attach by name.  This means the user can attempt to attach to interface
>>> "B" after detaching from interface "A".
>>>
>>> The driver is not designed to support this so check we are re-attaching
>>> to the right tun_struct.  Failure to do so may lead to oops.
>>>
>>> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
>> Applied.
> Hi David:
> 
> Any chance that I can have a respin on this patch, there's still a bug
> after this patch. Or I just can send a patch on top?

If I've applied it, there is no reverting.
