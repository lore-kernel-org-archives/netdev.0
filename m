From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Regarding SET_NETDEV_DEV
Date: Tue, 03 Jun 2003 23:27:40 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3EDD672C.2000701@pobox.com>
References: <20030603175921.GE2079@gtf.org> <20030603.200944.78736971.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030603.200944.78736971.davem@redhat.com>
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: Jeff Garzik <jgarzik@pobox.com>
>    Date: Tue, 3 Jun 2003 13:59:21 -0400
> 
>    For janitors and other developers placing this in net drivers...
>    please don't :)  This can be done in upper layers, accomplishing the
>    same goal without changing the low-level net driver code at all.
>    
> Don't say something can be done without showing exactly
> how :-)
> 
> How does register_netdevice() know that the device is "whatever" and
> where to get the generic device struct from?


Doh!  You are totally right -- it can't get the association any other 
way.  Folks, ignore me :)

	Jeff



