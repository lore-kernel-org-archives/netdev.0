From: netdev-bounce@oss.sgi.com
Subject: (no subject)
Date: Tue, 29 Oct 2002 17:10:12 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021029061012.ACCDA12CEA6@blammo.its.monash.edu.au>
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: undisclosed-recipients: ;
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Oct 2002, Nivedita Singhvi wrote:

> "Richard B. Johnson" wrote:
> 
> > No. It's done over each word (short int) and the actual summation
> > takes place during the address calculation of the next word. This
> > gets you a checksum that is practically free.
> 
> Yep, sorry, word, not byte. My bad. The cost is in the fact 
> that this whole process involves loading each word of the data
> stream into a register. Which is why I also used to consider
> the checksum cost as negligible. 
> 
> > A 400 MHz ix86 CPU will checksum/copy at 685 megabytes per second.
> > It will copy at 1,549 megabytes per second. Those are megaBYTES!
> 
> But then why the difference in the checksum/copy and copy?
> Are you saying the checksum is not costing you 864 megabytes
> a second??

Costing you 864 megabytes per second?
Lets say the checksum was free. You are then able to INF bytes/per/sec.
So it's costing you INF bytes/per/sec?  No, it's costing you nothing.
If we were not dealing with INF, then 'Cost' is approximately 1/N, not
N. Cost is work_done_without_checksum - work_done_with_checksum. Because
of the low-pass filter pole, these numbers are practically the same.
But, you can get a measurable difference between any two large numbers.
This makes the 'cost' seem high. You need to make it relative to make
any sense, so a 'goodness' can be expressed as a ratio of the cost and
the work having been done.

Cheers,
Dick Johnson
Penguin : Linux version 2.4.18 on an i686 machine (797.90 BogoMips).
   Bush : The Fourth Reich of America
