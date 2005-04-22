From: Baruch Even <baruch@ev-en.org>
Subject: Re: [RFC INTRO 0/5] H-TCP congestion control
Date: Fri, 22 Apr 2005 01:48:02 +0100
Message-ID: <426849C2.7000409@ev-en.org>
References: <20050311160734.30424.67955.65942@galon.ev-en.org> <20050311094239.4c59c29d@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S.Miller" <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com, Douglas Leith <doug.leith@nuim.ie>
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050311094239.4c59c29d@dxpl.pdx.osdl.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Fri, 11 Mar 2005 18:07:34 +0200 (IST)
> Baruch Even <baruch@ev-en.org> wrote:
> 
> 
>>The following patches are the result of the work of Douglas Leith to implement
>>the H-TCP congestion control proposal. They have since been modified by me
>>(Baruch Even) to port them to kernel 2.6.x, test them and tune them.
>>
>>All patches are against Linux kernel version 2.6.11-bk6. This is currently
>>a preliminary work and is presented for review in order to receive comments to
>>improve this work so it can be accepted to mainline Linux Kernel.
>>
>>The initial development was to add H-TCP to the Linux kernel for testing
>>purposes, it became evident that on 1 Gbit/s links Linux is unable to process
>>the received ack stream fast enough to handle the load. We have patches for
>>that but they proved too hard to be ported to 2.6.11+, we are currently working
>>on them.
>>
>>Baruch
> 
> 
> Are there any IPR encumberance to this like FAST TCP. Earlier versions of
> this patch said:
> 
> 
>>This patch is covered by a pending patent, a license is being worked on to
>>enable the inclusion in Linux. Comments and suggestions on this are also
>>solicited.
> 
> 
> Has this changed?

This has changed now. The code is now released under the GNU GPL v2, 
according to what I was told this effectively implies that any patent 
right that the university will have regarding this technology is 
effectively licensed for use with this code.

Please let me know if there is anything else that we need to do to let 
the review and possible inclusion of our contribution to proceed.

Baruch
