From: Ethan Sommer <sommere@ethanet.com>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Tue, 20 May 2003 00:07:33 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EC9B815.4000504@ethanet.com>
References: <1053313298.3909.5.camel@rth.ninka.net>
 <20030519202756.I39498@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-reply-to: <20030519202756.I39498@shell.cyberus.ca>
To: Jamal Hadi <hadi@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal Hadi wrote:

>Hi,
>
...

>BTW, i am not sure how efficient the stuff that Henry spencer
>wrote is in comparison to newer research on variants of boyer-moore
>for regex searches. comment?
>  
>
I picked Spencer's mainly because it was a pain to port the glibc 
version into kernel space. They are both basically the posix regexp 
interface, so if someone wants to get another version working in kernel 
space we can test and see which one performs better with real load 
pretty easily.


>The code also does seem inefficient but thats beside the point at the
>moment (ex you seem to malloc for every incoming packet so you can do a
>regex).
>  
>
Yep. We haven't spent a lot of time on optimizations. Obviously that 
example can be fixed pretty quickly... except I'm not sure we can avoid 
it and stay thread safe? (linux can route multiple packets at the same 
time on an smp box right? so we can't just use a staically defined 
buffer...)

Ethan Sommer
http://l7-filter.sf.net
