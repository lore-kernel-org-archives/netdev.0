From: Ben Greear <greearb@candelatech.com>
Subject: Re: gigabit ethernet
Date: Sun, 15 Feb 2004 20:32:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <403047C9.8020908@candelatech.com>
References: <20040214140914.3341.qmail@web21107.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cheng Jin <chengjin@cs.caltech.edu>,
        "Xiaoliang (David) Wei" <weixl@caltech.edu>,
        "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: satya srikanth <satyasrikanth2001@yahoo.com>
In-Reply-To: <20040214140914.3341.qmail@web21107.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

satya srikanth wrote:

> My CPU is unable to handle anything more than this. Is
> it possible to handle 1000Mbps for any packet size or
> atleast something better than this by using more
> powerful machines. If anyone of you have experimented
> with this, can you give an idea of what kind of a
> machine do I need for this. 

Try a machine with a 64/66 PCI bus, or preferably,
a PCI-X bus that can run 64/100 or better.

I got line speed packet generation and reception on
a dual 2.8Ghz Xeon machine with PCI-X (64/100) bus and a dual
port Intel pro/1000 NIC.  I tested with 1500 byte packets
and transmitted and received 999Mbps of traffic between
two ports (total of ~4Gbps across the PCI backplane).

I wasn't routing or anything like that, but at least for
packet generation it worked fine.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
