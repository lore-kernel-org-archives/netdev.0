From: Luiz Fernando Capitulino <lcapitulino@conectiva.com.br>
Subject: Re: [patch 10/13] net/socket.c::sys_bind() cleanup.
Date: Wed, 24 Nov 2004 08:55:10 -0200
Message-ID: <41A4688E.80908@conectiva.com.br>
References: <200411220644.iAM6i8900672@mail.osdl.org> <20041124002709.52cb8d1f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041124002709.52cb8d1f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Sun, 21 Nov 2004 22:43:56 -0800
> akpm@osdl.org wrote:
> 
> 
>>From: "Luiz Fernando N. Capitulino" <lcapitulino@conectiva.com.br>
>>
>>net/socket.c::sys_bind() is a bit complex function, the patch below makes
>>it more clear.
>>
>>Signed-off-by: Luiz Capitulino <lcapitulino@conectiva.com.br>
>>Signed-off-by: Andrew Morton <akpm@osdl.org>
> 
> 
> This was commented on to be buggy, or at least change behavior.
> The "if (err >= 0)" tests were changed to flat "if (err)" tests.

  It doesn't a buggy or change behaivor.

  What happens here is that move_addr_to_kernel() returns 0
success and -EINVAL or -EFAULT on error. Thus, change from
"if (err >= 0)" to "if (err)" is safe.

  Also, it was discussed and ACK'ed by James Morris:

http://lkml.org/lkml/2004/11/16/339

  The real problem here I've made a bad patch
description. I'll try to make it better next time.

  thanks,

-- 
Luiz Fernando N. Capitulino
