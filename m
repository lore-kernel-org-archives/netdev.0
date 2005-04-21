From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH net-drivers-2.6 5/6] e100: Performance optimizations to
 e100 Tx Path
Date: Thu, 21 Apr 2005 10:10:52 -0700
Message-ID: <20050421101052.4d212a17.rddunlap@osdl.org>
References: <Pine.LNX.4.61.0504190534410.11186@anoushka.jf.intel.com>
	<20050420200524.3e284eb9.rddunlap@osdl.org>
	<5fc59ff305042109514b792bbf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mallikarjuna.chilakala@intel.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
In-Reply-To: <5fc59ff305042109514b792bbf@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Apr 2005 09:51:01 -0700 Ganesh Venkatesan wrote:

| 
| > |  static inline int e100_exec_cmd(struct nic *nic, u8 cmd, dma_addr_t dma_addr)
| > |  {
| > |       unsigned long flags;
| > | @@ -847,6 +847,10 @@ static inline int e100_exec_cb(struct ni
| > |                        * because the controller is too busy, so
| > |                        * let's just queue the command and try again
| > |                        * when another command is scheduled. */
| > | +                     if(err == -ENOSPC) {
| >                         if (err == -ENOSPC) {
| > is preferred (with space after if).
| > (same comment for below)
| 
| Is there a clear directive on 'if(' versus 'if ('? I see both styles
| being used. We are trying to stay consistent with 'if('.

There's nothing explicit in CodingStyle, but all of
the examples in CodingStyle use a space after 'if'.

And a few if's in this driver use a space after 'if',
but most don't iirc from counting them yesterday.

Thanks,
---
~Randy
