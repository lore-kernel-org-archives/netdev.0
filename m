From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5 0/3] ARM: shmobile: lager: enable Ether
Date: Fri, 26 Jul 2013 18:33:49 +0400
Message-ID: <51F288CD.60608@cogentembedded.com>
References: <1374656169-9241-1-git-send-email-horms+renesas@verge.net.au> <3554825.Zlt5jMD3jh@avalon> <20130726005506.GD28912@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20130726005506.GD28912@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 26-07-2013 4:55, Simon Horman wrote:

>>> this short series enables the on-board ethernet
>>> of the r8a7790 SoC for on lager board.

>>> It has a run-time dependency on
>>> "sh_eth: add support for r8a7790 SoC"

>>> It has been built on top of renesas-next-20130724v2.

>>> Simon Horman (3):
>>>    ARM: shmobile: r8a7790: clocks for Ether support
>>>    ARM: shmobile: lager: enable Ether
>>>    ARM: shmobile: lager: enable nfsroot in DTS

>>>   arch/arm/boot/dts/r8a7790-lager.dts    |  2 +-
>>>   arch/arm/mach-shmobile/board-lager.c   | 30 ++++++++++++++++++++++++++++++
>>>   arch/arm/mach-shmobile/clock-r8a7790.c |  4 ++++
>>>   3 files changed, 35 insertions(+), 1 deletion(-)

>> With this series and "[PATCH 0/2 v4 net-next repost] sh_eth: Add support for
>> r8a7790 SoC" applied on top of renesas-devel-20130725, booting the Lager
>> board usually (about 90% of the time) results in receive FIFO overflows and
>> disabling of the sh-eth IRQ:

    Looking at the trace, disabling of IRQ is probably caused by something 
other than RX FIFO overflow (when it caused disabling IRQ, there were no error 
messages printed because RFE interrupt went completely unhandled). Probably 
there's more interrupt mask issues lurking in the driver...

> Thanks.

> Unfortunately I am having trouble with using NFS root at all
> in my test environment. I'll work with Magnus to resolve this issue.

> Sergei do you have any idea what might be causing this?

    No idea. I still don't have access to Lager and on BOCK-W we have no 
issues with NFS. What are your symptoms?

WBR, Sergei

