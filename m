From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] uapi: fix linux/if.h userspace compilation errors
Date: Wed, 22 Feb 2017 16:09:28 -0500 (EST)
Message-ID: <20170222.160928.487250706697602435.davem@davemloft.net>
References: <20170220115841.GA6846@altlinux.org>
        <20170221.121022.676021611021776681.davem@davemloft.net>
        <20170221201914.GA28360@altlinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ldv@altlinux.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170221201914.GA28360@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Tue, 21 Feb 2017 23:19:14 +0300

> On Tue, Feb 21, 2017 at 12:10:22PM -0500, David Miller wrote:
>> From: "Dmitry V. Levin" <ldv@altlinux.org>
>> Date: Mon, 20 Feb 2017 14:58:41 +0300
>> 
>> > Include <sys/socket.h> (guarded by ifndef __KERNEL__) to fix
>> > the following linux/if.h userspace compilation errors:
>> 
>> Wouldn't it be so much better to do this in include/uapi/linux/socket.h?
> 
> Yes, it would be nicer if we could afford it.  However, changing
> uapi/linux/socket.h to include <sys/socket.h> is less conservative than
> changing every uapi header that fails to compile because of its use
> of struct sockaddr.  It's risky because <sys/socket.h> pulls in other
> types that might conflict with definitions provided by uapi headers.

Ok, I'll apply this for now.
