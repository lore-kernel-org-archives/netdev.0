From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] switch arcnet over to initcalls
Date: Wed, 21 May 2003 23:02:11 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521.230211.15256464.davem@redhat.com>
References: <20030521221638.A7575@lst.de>
	<20030521.162052.08332261.davem@redhat.com>
	<20030522075711.A11759@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20030522075711.A11759@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Christoph Hellwig <hch@lst.de>
   Date: Thu, 22 May 2003 07:57:11 +0200
   
   It's not probed from Space.c so it's probed after most isa devices
   anyway.

Yes it is, because com90xx init was being done via arcnet init.
Which in turn was being done in Space.c and looks to be SPECIFICALLY
being invoked after ethernet ISA devices are probed.

   You can't just veto all initcall changes because they are isa
   devices

I absolutely can.  Until someone can document the dependencies
I have every right to reject this change because it's effects
are unknown to actual users.

You can't even test your changes.
