From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH 6/8] Use SLAB_PANIC when creating critical slab cache
Date: Sun, 14 Nov 2004 21:51:59 -0200
Message-ID: <4197EF9F.50300@conectiva.com.br>
References: <20041114121837.X2357@build.pdx.osdl.net> <20041114122400.D2357@build.pdx.osdl.net> <4197BFC5.5080800@conectiva.com.br> <20041114145157.G2357@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20041114145157.G2357@build.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Chris Wright wrote:
> * Arnaldo Carvalho de Melo (acme@conectiva.com.br) wrote:
> 
>>Chris,
>>
>>	I think somebody proposed this in the past and it was refused
>>because we better get rid of the panics and return an error, propagate
>>it and refuse to load the module, better have the machine still alive
>>but without networking than panic it.
> 
> 
> Sounds good too.  Part of my thinking was that these patches would be a
> good chance to review if these are necessarily panic conditions.  What was
> the plan on error return, since I expect some caches are interdependent?

I lost track, perhaps we should push this to the janitor mailing list?

:-)

- Arnaldo
