From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: Dump of TCP hang in established state
Date: 21 May 2003 21:54:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1053546862.9483.18.camel@tux.rsn.bth.se>
References: <Mutt.LNX.4.44.0305141907210.9712-100000@excalibur.intercode.com.au>
	 <3ECBB522.9080101@us.ibm.com> <1053545510.9476.9.camel@tux.rsn.bth.se>
	 <3ECBCC5A.6090406@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@intercode.com.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <3ECBCC5A.6090406@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-05-21 at 20:58, Nivedita Singhvi wrote:
> Martin Josefsson wrote:
> 
> >>Can anyone tell me what to do to reproduce this?
> > 
> > I've now tried my distcc stuff again. With TCP_CORK enabled I don't have
> > any problem reproducing the hangs, 1 in 3 shows at least one hang. But
> > so far I havn't been able to reproduce it with TCP_CORK disabled. I'll
> > keep compiling a few more times, I've only run 10 compilations so far.
> > 
> > When using distcc you know you have a hang when it stops at the
> > object-linking for a while waiting for one process to finish.
> > 
> 
> Thanks, Martin..
> 
> Which kernels are you currently using?
> Were you able to reproduce this with 2.5.69 at both
> ends?

I'm using 2.5.69-mm5 on the client and 2.4.20 and 2.4.21-rc1 on the
servers. Also seen with 2.5.67 and earlier on the client.

I did run 2.4.19 on the client and never saw this problem with that
kernel.

I can't test 2.5 kernels on the servers since they are actually routers
located a fair bit away from here so I do not want to test 2.5 on them
just yet.

> I just took a look at your previous trace. I'n not absolutely
> sure my previous report of a hang is the same issue, only because
> in that case the connection did not revive, whereas in your
> case after the 1 second approximate stall, it continues..
> (havent stepped through everything yet).

I don't get a 1 second stall, I get a long stall, around 2 minutes and
then when the timer (seen with netstat -o) on the clientside expires it
continues like nothing happened. So it's not fatal, just very irritating
when using distcc to speed up compiles and then you end up having to
wait :)

-- 
/Martin
