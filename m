From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Dump of TCP hang in established state
Date: Wed, 21 May 2003 11:58:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3ECBCC5A.6090406@us.ibm.com>
References: <Mutt.LNX.4.44.0305141907210.9712-100000@excalibur.intercode.com.au>	 <3ECBB522.9080101@us.ibm.com> <1053545510.9476.9.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@intercode.com.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <1053545510.9476.9.camel@tux.rsn.bth.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Martin Josefsson wrote:

>>Can anyone tell me what to do to reproduce this?
> 
> I've now tried my distcc stuff again. With TCP_CORK enabled I don't have
> any problem reproducing the hangs, 1 in 3 shows at least one hang. But
> so far I havn't been able to reproduce it with TCP_CORK disabled. I'll
> keep compiling a few more times, I've only run 10 compilations so far.
> 
> When using distcc you know you have a hang when it stops at the
> object-linking for a while waiting for one process to finish.
> 

Thanks, Martin..

Which kernels are you currently using?
Were you able to reproduce this with 2.5.69 at both
ends?

I just took a look at your previous trace. I'n not absolutely
sure my previous report of a hang is the same issue, only because
in that case the connection did not revive, whereas in your
case after the 1 second approximate stall, it continues..
(havent stepped through everything yet).

thanks,
Nivedita
