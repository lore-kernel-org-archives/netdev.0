From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Bug-hunting
Date: Tue, 22 Feb 2005 10:44:48 -0800
Message-ID: <20050222104448.31373a99.davem@davemloft.net>
References: <421B4AB7.9030003@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
In-Reply-To: <421B4AB7.9030003@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Feb 2005 16:07:35 +0100
Christian Schmid <webmaster@rapidforum.com> wrote:

> I am still trying to hunt down the bug with the slowdown-on-many-sockets. Is there any way I can see 
> how much tcp-memory is used right now? Why did you change the behaviour? In 2.6.10-rc2 I was able to 
> see the amount by looking in slabinfo but now the buffers are gone. And where did you introduce the 
> buffer-limit? It seems its now globally limited to xxx MB. I want to disable this in order to check 
> if thats the reason.

The global TCP memory limit, controllable by sysctl()'s, has been there for
at least 3 years.
