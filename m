From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: Wed, 23 Oct 2002 11:07:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB6E56D.8D930A1D@us.ibm.com>
References: <Pine.LNX.3.95.1021023133435.14975B-100000@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bert hubert <ahu@ds9a.nl>, Roy Sigurd Karlsbakk <roy@karlsbakk.net>,
   "David S. Miller" <davem@rth.ninka.net>, netdev@oss.sgi.com,
   Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: root@chaos.analogic.com
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
