From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 10/13] net/socket.c::sys_bind() cleanup.
Date: Wed, 24 Nov 2004 00:27:09 -0800
Message-ID: <20041124002709.52cb8d1f.davem@davemloft.net>
References: <200411220644.iAM6i8900672@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        lcapitulino@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200411220644.iAM6i8900672@mail.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 21 Nov 2004 22:43:56 -0800
akpm@osdl.org wrote:

> From: "Luiz Fernando N. Capitulino" <lcapitulino@conectiva.com.br>
> 
> net/socket.c::sys_bind() is a bit complex function, the patch below makes
> it more clear.
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@conectiva.com.br>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

This was commented on to be buggy, or at least change behavior.
The "if (err >= 0)" tests were changed to flat "if (err)" tests.
