From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: Dump of TCP hang in established state
Date: 21 May 2003 21:31:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1053545510.9476.9.camel@tux.rsn.bth.se>
References: <Mutt.LNX.4.44.0305141907210.9712-100000@excalibur.intercode.com.au>
	 <3ECBB522.9080101@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@intercode.com.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <3ECBB522.9080101@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-05-21 at 19:19, Nivedita Singhvi wrote:

> >>I think this is what I've seen a few times when using distcc.
> > 
> > Does anyone know if the other hangs are seen when the app is using 
> > TCP_CORK (like distcc does) ?
> 
> We had observed some hangs during SpecWeb99 benchmark runs.
> Unfortunately, we managed to burn down the machine and have
> yet to rerun the benchmark. No other workload seems to
> be observing them.
> 
> I'm trying to excavate the one incomplete trace I had of
> that hang, if possible. IIRC it was using sendfile(), so
> probably also using TCP_CORK, though dont know that for
> sure.
> 
> Can anyone tell me what to do to reproduce this?

I've now tried my distcc stuff again. With TCP_CORK enabled I don't have
any problem reproducing the hangs, 1 in 3 shows at least one hang. But
so far I havn't been able to reproduce it with TCP_CORK disabled. I'll
keep compiling a few more times, I've only run 10 compilations so far.

When using distcc you know you have a hang when it stops at the
object-linking for a while waiting for one process to finish.

-- 
/Martin
