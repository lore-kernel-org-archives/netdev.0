From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: packet socket can't steal packets
Date: Wed, 08 May 2002 09:49:53 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CD92D01.A4AD708@nortelnetworks.com>
References: <Pine.OSF.4.30.0205072042410.30796-100000@kosh.hut.fi> <19900103212500.A4614@ratula.chimaira.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Carl-Johan Bostorp <ctor@krixor.xy.org>
List-Id: netdev.vger.kernel.org

Carl-Johan Bostorp wrote:
> 
> On Tue, May 07, 2002 at 09:02:31PM +0300, Dmitrii Tisnek wrote:
> > hey, I've been trying to change certain network packet mangling software
> > such that it would not need a kernel module, and it seems to me that,
> > unfortunately there's no way to make packet socket "steal" packets it
> > deliveres to the user mode.
> 
> "Divert Sockets for Linux" springs to my mind..
> 
> http://www.anr.mcnc.org/~divert/index.shtml

Except that the original poster is using the 2.4 kernel, for which divert
sockets do not work.

For 2.4 the netfilter module is cleanest, followed by netfilter QUEUE to
userspace (although this will give a performance hit).

When I had to move from 2.2 with divert sockets to 2.4, I used a netfilter
module with commandline parameters to pass in arguments.

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10  
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
