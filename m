From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 2/2] ipvs deadlock fix
Date: Tue, 15 Feb 2005 14:27:38 -0800
Message-ID: <20050215142738.6216e197.davem@davemloft.net>
References: <200501310633.j0V6X1l01385@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, akpm@osdl.org
To: akpm@osdl.org
In-Reply-To: <200501310633.j0V6X1l01385@mail.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 30 Jan 2005 22:33:02 -0800
akpm@osdl.org wrote:

> update_defense_level() is calling si_meminfo() from timer context.  But
> si_meminfo takes non-irq-safe locks.
> 
> Move it all to keventd context.  
> 
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Ok, both patches applied.  I'll push it upstream in 2.6.12
