From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: PATCH: bonding might sleep with lock held
Date: Thu, 13 May 2004 12:34:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405131934.i4DJYnk6018519@death.nxdomain.ibm.com>
References: <20040513210445.3e08c1f4.ak@suse.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: Your message of "Thu, 13 May 2004 21:04:45 +0200."
             <20040513210445.3e08c1f4.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Andi Kleen <ak@suse.de> wrote:
>On Thu, 13 May 2004 11:44:45 -0700
>Jay Vosburgh <fubar@us.ibm.com> wrote:
>
>> 	It will race against the timers, although I don't see anything
>> in there offhand that would conflict.  It just feels somehow unclean to
>> do it without the lock.
>
>Why should the timers care if there can be a packet received from the 
>network or not?  (this is all what dev_remove_pack prevents) 

	The concern I had was that the timers might modify the fields of
the bonding structure accessed outside the lock, but they don't.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
