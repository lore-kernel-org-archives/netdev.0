From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/4] net: implement support for low latency
 socket polling
Date: Mon, 20 May 2013 02:16:14 -0700 (PDT)
Message-ID: <20130520.021614.1748558994745374855.davem@davemloft.net>
References: <20130519102533.12527.12991.stgit@ladj378.jer.intel.com>
	<20130520.005447.972811583292360876.davem@davemloft.net>
	<1369038587.2143.12.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eliezer.tamir@linux.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	donanld.c.skidmore@intel.com, e1000-devel@lists.sourceforge.net,
	willemb@google.com, andi@firstfloor.org, hpa@zytor.com,
	eliezer@tamir.org.il
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369038587.2143.12.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 20 May 2013 01:29:47 -0700

> On Mon, 2013-05-20 at 00:54 -0700, David Miller wrote:
>> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> []
>> >  {
>> >       struct socket *sock;
>> > +     unsigned int poll_result;
>> 
>> Please order local variable declarations from longest line to
>> shortest line.
> 
> reverse christmas tree doesn't seem especially valuable or
> sensible for automatics.

It looks nicer to the eyes and provides a predictable pattern
to look at.
