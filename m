From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Dump of TCP hang in established state
Date: Thu, 29 May 2003 14:50:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3ED68090.5040903@us.ibm.com>
References: <1052841090.13492.20.camel@tux.rsn.bth.se>	 <20030529.024114.78714066.davem@redhat.com>	 <1054217010.757.39.camel@tux.rsn.bth.se> <1054238230.709.1.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <1054238230.709.1.camel@tux.rsn.bth.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Martin Josefsson wrote:

> I've just tested 2.5-bk and I can still reproduce it.
> The wording of my mail might have been a bit wrong, I don't see complete
> hangs, just ~2 minute stalls in ESTABLISHED state and then it continues
> like nothing happened.
> 

This actually addresses a situation of memory corruption
and illegal reference panics, correct? And should potentially
fix such issues or other seeming weirdnesses that might be
happening in both sendmsg() and sendfile() code paths? Any other
symptoms or particulars? I'm wondering if this addresses
might explain some other bugs we have run into (not
identified as TCP yet)?


thanks,
Nivedita
