From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Dump of TCP hang in established state
Date: Wed, 21 May 2003 10:19:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3ECBB522.9080101@us.ibm.com>
References: <Mutt.LNX.4.44.0305141907210.9712-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Martin Josefsson <gandalf@wlug.westbo.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: <Mutt.LNX.4.44.0305141907210.9712-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Morris wrote:

>>- There are those mysterious TCP hangs of established state sockets. 
>>  Someone has to get a good log in order for us to effectively debug this.
>>
>>I think this is what I've seen a few times when using distcc.
> 
> Does anyone know if the other hangs are seen when the app is using 
> TCP_CORK (like distcc does) ?

We had observed some hangs during SpecWeb99 benchmark runs.
Unfortunately, we managed to burn down the machine and have
yet to rerun the benchmark. No other workload seems to
be observing them.

I'm trying to excavate the one incomplete trace I had of
that hang, if possible. IIRC it was using sendfile(), so
probably also using TCP_CORK, though dont know that for
sure.

Can anyone tell me what to do to reproduce this?

Also, I'd like to have this tracked in bugzilla, if noone
objects (DaveM?), so we dont lose it..I had dropped some earlier
reports of hangs. I'll file in BUGME..

thanks,
Nivedita
