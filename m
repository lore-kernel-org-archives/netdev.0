From: netdev-bounce@oss.sgi.com
Subject: (no subject)
Date: Tue, 29 Oct 2002 17:14:53 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021029061453.5183C12C989__1795.2581904412$1035891365@blammo.its.monash.edu.au>
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: undisclosed-recipients: ;
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Richard B. Johnson" wrote:

> No. It's done over each word (short int) and the actual summation
> takes place during the address calculation of the next word. This
> gets you a checksum that is practically free.

Yep, sorry, word, not byte. My bad. The cost is in the fact 
that this whole process involves loading each word of the data
stream into a register. Which is why I also used to consider
the checksum cost as negligible. 

> A 400 MHz ix86 CPU will checksum/copy at 685 megabytes per second.
> It will copy at 1,549 megabytes per second. Those are megaBYTES!

But then why the difference in the checksum/copy and copy?
Are you saying the checksum is not costing you 864 megabytes
a second??

thanks,
Nivedita
