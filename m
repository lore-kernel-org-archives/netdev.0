From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Wed, 08 Jan 2003 15:56:34 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E1CBAB2.78FE168A@us.ibm.com>
References: <Pine.LNX.4.33.0301081451110.2281-100000@dyn9-47-18-86.beaverton.ibm.com> <20030108.150638.09647984.davem@redhat.com> <3E1CAACB.5D1B82DB@us.ibm.com>
Reply-To: niv@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, sri@us.ibm.com, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Grimm <jgrimm2@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Grimm wrote:
> 
> "David S. Miller" wrote:
> >
> >    From: Sridhar Samudrala <sri@us.ibm.com>
> >    Date: Wed, 8 Jan 2003 15:04:53 -0800 (PST)

> > Sigh... I guess the new argument to ip_queue_xmit() is the least
> > intrusive.
> 
> I hate to mention it, but there is at least one other alternative (to
> complete the picture) that is to chunk up the messages into their
> smallest fragment and then bundle these chunks up to the MTU allowable
> packet.
> This however does each up space in the packet for each chunk header and
> require more processing at the other end to reassemble the records.
> 
> IIRC, this is what OpenSS7s SCTP does, while the KAME SCTP manually
> controls the DF bit as per Sridhar's suggestion.   There are tradeoffs
> in either approach.

Jon, from the performance standpoint, that would be the least
preferred approach, right? Also, adding the argument to ip_queue_xmit()
would at least be a general solution for other possible protocols,
raw apps, etc or features that might want to make use of it..
(heaven forbid ;))..

thanks,
Nivedita
