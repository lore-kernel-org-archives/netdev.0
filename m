From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Fw: [Kernel-janitors] old ioctl definitions in 2.5
Date: Mon, 15 Sep 2003 16:57:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309152357.h8FNvQ73013361@death.ibm.com>
References: <davem@redhat.com>
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, netdev@oss.sgi.com,
   janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: Message from "David S. Miller" <davem@redhat.com>
   of "Mon, 15 Sep 2003 15:54:15 PDT." <20030915155415.73c5056d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>On Mon, 15 Sep 2003 15:52:25 -0700
>"Randy.Dunlap" <rddunlap@osdl.org> wrote:
>
>> I think that we need to ask the netdev people about this...
>
>If the current generation of the bonding userland tools
>have stopped using these older ioctl values, yes we should
>kill them from the entire kernel tree.

	The current user and kernel bonding code both still use these,
although I agree that they can go away (the versions of bonding old
enough to still need them are very old indeed).  I don't see a need to
keep them in 2.4, either, as the real SIOCBONDwhatever ioctls date
back at least two years.

	My only concern is a matter of timing; we're right at the end
of synchronizing the 2.4 and 2.6 bonding sources.  Once that's settled
(hopefully in a few days, the last patch set for 2.4 came in this
morning), then removing them from that header and the bonding code
should be fine.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
