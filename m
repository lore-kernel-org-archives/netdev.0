From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.11 on AMD64 traps
Date: Wed, 09 Mar 2005 22:05:27 +0100
Message-ID: <422F6517.6070301@trash.net>
References: <200503081900.18686.vanco@satro.sk> <200503092124.35190.vanco@satro.sk> <422F5DF0.6060904@trash.net> <200503092142.50027.vanco@satro.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Michal Vanco <vanco@satro.sk>
In-Reply-To: <200503092142.50027.vanco@satro.sk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michal Vanco wrote:
> On Wednesday 09 March 2005 21:34, Patrick McHardy wrote:
>>
>>Yes, I know it is totally inefficient. Just use ip route, which doesn't
>>suffer from this problem.
> 
> Sure. Can (or will) this ever be fixed to any usable state also with netstat?
> Is this problem related only to AMD64?

Maybe. To start dumping entries of an open hashed hash-table at a
specific position we need to skip all entries before that position by
walking over them. This results in quadratic time complexity. It might
be possible to improve this by cacheing the last position in
fib_iter_state even between ->stop() and ->start() calls and using
generation IDs for invalidation.

Regards
Patrick
