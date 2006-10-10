From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: socket/IP on Linux
Date: Tue, 10 Oct 2006 15:45:33 -0300
Message-ID: <39e6f6c70610101145i4f23c67cn15b71432ceab7dc5@mail.gmail.com>
References: <20061005211707.61196.qmail@web30514.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:8527 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1750750AbWJJSpf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 14:45:35 -0400
Received: by wx-out-0506.google.com with SMTP id s14so1909697wxc
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2006 11:45:34 -0700 (PDT)
To: "Jingping Lin" <jplin_99@yahoo.com>
In-Reply-To: <20061005211707.61196.qmail@web30514.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/5/06, Jingping Lin <jplin_99@yahoo.com> wrote:
> Hello, Linux Kernel:
> For a project I will work on for mobile, I am looking
> into the IP stacks on Linux.
>
> I have a few questions to bother you:

No bothering, so far, please see the below answers and try to check
them all before "bothering" again 8)

> 1. is "socket.c" the file handling the socket
> interface?

One of them

> 2. which function is for opening a socket?
> It looks like "sock_map_fd()" is the one for
> opening/creating a socket? Is that correct?
> The "Linux IP Stacks Commentary" book suggested the
> function is "int socket()" which I didn't find in
> "socket.c" though.

Perhaps it is suggesting that you create the socket in userspace using
the libc socket(2) function (see 'man socket') and then passing it
thru some ioctl if you want to use kernel_sendmsg (make tags ; vi -t
kernel_sendmsg) from kernelspace?

> 3. Do you have documentations discussing in details
> the implemented socket interfaces?

Humm, I guess you can grep the sources for in kernel socket usage?

> Thanks a lot in advance for your help,

Best Regards,

- Arnaldo
