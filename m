From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] fix natsemi PCI mapping
Date: Tue, 16 Mar 2004 14:20:20 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40575374.6080006@pobox.com>
References: <40574227.8020302@pobox.com> <4057525E.6020205@timesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Tim Hockin <thockin@sun.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	ralf@linux-mips.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "Steven J. Hill" <Steve.Hill@timesys.com>
In-Reply-To: <4057525E.6020205@timesys.com>
List-Id: netdev.vger.kernel.org

Steven J. Hill wrote:
> Jeff Garzik wrote:
> 
>>
>> Somebody wanna review and/or test?
>>
> Hey Jeff.
> 
> I have tested this on 2.4 and it works great on MIPS with one
> minor change below. Remove the 16 byte alignment of the IP
> header. I discovered this when trying to do a BOOTP and mount
> my NFS root filesystem. The BOOTP never succeeds. Patch against
> latest 2.4.25 attached.


Interesting, thanks.

WRT skb_reserve(), I wonder if

(a) RX_OFFSET value passed to skb_reserve() needs to be per-arch
(b) the pre-existing skb_reserve() call is wrong too
