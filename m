From: Dan Kegel <dank@kegel.com>
Subject: Re: Atomic.h for PPC
Date: Thu, 09 Oct 2003 08:59:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F8585EC.3040908@kegel.com>
References: <41DD7618430DD411870400D0B746EDED0DC82C4F@mail.tms-ltd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Solmaz Mustafa <mustafa.solmaz@uk.thalesgroup.com>
In-Reply-To: <41DD7618430DD411870400D0B746EDED0DC82C4F@mail.tms-ltd.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Solmaz Mustafa wrote:
> I am trying to develop a program on PowerPC and as trying to use LOKI's
> smart pointers I had some problems of compilation. 
> Loki's headers use atomic_inc_and_test() and atomic_dec_and_test() atomic
> operations for multi-threaded purpose. Those methods are available in many
> of Linux Kernel APIs but in the one for Power PCs. Almost all
> /usr/include/asm/atomic.h files have those methods well defined but on Power
> PCs. 
> 
> My atomic.h is 11th version and that it has atomic_inc_return() method which
> I suppose will be used later as atomic_inc_and_test() method.
> Would you please show me a way to sort out this problem? I can write my own
> methods using the current atomic.h but I just do not know how to implement
> it in a safe way. 

This is off-topic for linux-net.
Please try posting your question on a more appropriate group,
e.g. one of the lists at http://lists.linuxppc.org/

I have a feeling you're writing a user-mode program, so you
shouldn't care about the kernel's atomic operations.  Since
you seem to be using c++, I'd suggest having a look at
http://gcc.gnu.org/onlinedocs/porting/Thread-safety.html#Thread%20safety
and maybe searching the archives of the gcc or libstdc++ mailing
lists for similar questions.
- Dan

-- 
Dan Kegel
http://www.kegel.com
http://counter.li.org/cgi-bin/runscript/display-person.cgi?user=78045
