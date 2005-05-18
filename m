From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 15:39:00 -0700
Message-ID: <428BC404.7000404@us.ibm.com>
References: <OFD80D42F2.31DFC921-ON88257005.007ABBCD-88257005.007B23EA@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        netdev-bounce@oss.sgi.com, rick.jones2@hp.com,
        Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFD80D42F2.31DFC921-ON88257005.007ABBCD-88257005.007B23EA@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> netdev-bounce@oss.sgi.com wrote on 05/18/2005 02:46:54 PM:
> 
> 
>>Thomas Graf <tgraf@suug.ch> wrote:
>>
>>>Wild thought: We could introduce a new ip option stating that the id
>>>generator uses a serial approach which would give us the possibility
>>>to measure the absolute distance and resolve this issue in a perfect
>>>matter for everyone supporting this extension. ;->
> 
> 
>>Well Linux does that anyway (apart from Suse) so all we need to do
>>is to tell everyone doing NFS over gigabit to use Linux :)
> 
> 
>         If you're going to add an IP option, you can eliminate the
> problem entirely. Just add an "extended IP ID" IP option and give
> it as many bits as you want-- make that the high order of an n+16-bit
> IP ID.
>         The IP timestamp option, if done per frag and required to be
> the same for all frags, could be used in this way, since you
> presumably won't wrap without incrementing that by at least 1. :-)
> 
>                                                         +-DLS

Whatever happened to UDP Path MTU? While we're at this, can't
we start kicking some path-MTU-broken butt?


thanks,
Nivedita
