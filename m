From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: 2.4.21: bug report for tg3:  tx lockup when changing MTU
Date: Fri, 01 Aug 2003 19:57:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2AFE7A.10203@pobox.com>
References: <3F2AEFBF.3040604@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F2AEFBF.3040604@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> I just noticed that if you change the MTU of a tg3 NIC, it will not work
> untill you ifdown/ifup it.  This problem is repeatable on tg3, and does not
> happen with the e1000 driver/cards.
> 
> I am setting the MTU via an ioctl call, not via ifconfig or something like
> that.


Can you provide the ioctl call info, so I can reproduce?

And, are you changing MTU when the interface is up or down?
