From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: design for TSO performance fix
Date: Thu, 27 Jan 2005 22:44:43 -0800
Message-ID: <41F9DF5B.6050305@us.ibm.com>
References: <20050127163146.33b01e95.davem@davemloft.net> <m1zmyu2hot.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m1zmyu2hot.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

> I looked at this some time ago to pass lists of packets
> to qdisc and hard_queue_xmit, because that would allow less locking
> overhead and allow some drivers to send stuff more efficiently
> to the hardware registers
> (It was one of the items in my "how to speed up the stack" list ;-) 
> 
> I never ended up implementing it because TSO gave most of the advantages
> anyways.

I admit that it's been several months since I last looked
at this - and was just handwaving, had no code. But I had
thought the converse then - that it might be better
to abandon TSO and just have the stack pass down the list
of skbs in one pass. Had been mentioned by Andi as well as
Anton. We'd get much of the gain, avoid a lot of the
complexity, and the code would be simpler. And I'm not
positive about this but it seemed it would handle memory
fragmentation better, too.

Bogus?

thanks,
Nivedita
