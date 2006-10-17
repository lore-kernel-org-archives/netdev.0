From: Jingping Lin <jplin_99@yahoo.com>
Subject: Re: socket/IP on Linux
Date: Mon, 16 Oct 2006 18:39:56 -0700 (PDT)
Message-ID: <20061017013956.73510.qmail@web30504.mail.mud.yahoo.com>
References: <39e6f6c70610101145i4f23c67cn15b71432ceab7dc5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web30504.mail.mud.yahoo.com ([68.142.200.117]:36453 "HELO
	web30504.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1030216AbWJQBj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 21:39:57 -0400
To: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
In-Reply-To: <39e6f6c70610101145i4f23c67cn15b71432ceab7dc5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Arnaldo:
Sorry, I have to bother you again with another Linux
socket question.

Suppose that I have a Linux IP socket connected for a
TCP connection and the socket is set as a non-blocking
one with fcntl().

Even the socket is set as non-blocking, is it really
possible to perform Non-Blocking Close on this socket?
i.e., can I make the "int=close(fd)" a non-blocking
call? 

The answer seems No to me based on my study. I am not
totally sure though.

If the answer is Yes, how?

Please help, thanks a lot,
Jingping
  
--- Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
wrote:

> On 10/5/06, Jingping Lin <jplin_99@yahoo.com> wrote:
> > Hello, Linux Kernel:
> > For a project I will work on for mobile, I am
> looking
> > into the IP stacks on Linux.
> >
> > I have a few questions to bother you:
> 
> No bothering, so far, please see the below answers
> and try to check
> them all before "bothering" again 8)
> 
> > 1. is "socket.c" the file handling the socket
> > interface?
> 
> One of them
> 
> > 2. which function is for opening a socket?
> > It looks like "sock_map_fd()" is the one for
> > opening/creating a socket? Is that correct?
> > The "Linux IP Stacks Commentary" book suggested
> the
> > function is "int socket()" which I didn't find in
> > "socket.c" though.
> 
> Perhaps it is suggesting that you create the socket
> in userspace using
> the libc socket(2) function (see 'man socket') and
> then passing it
> thru some ioctl if you want to use kernel_sendmsg
> (make tags ; vi -t
> kernel_sendmsg) from kernelspace?
> 
> > 3. Do you have documentations discussing in
> details
> > the implemented socket interfaces?
> 
> Humm, I guess you can grep the sources for in kernel
> socket usage?
> 
> > Thanks a lot in advance for your help,
> 
> Best Regards,
> 
> - Arnaldo
> 


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
