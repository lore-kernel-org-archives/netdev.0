From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP-Protection is really a pain...
Date: Wed, 2 Feb 2005 20:54:37 -0800
Message-ID: <20050202205437.571a702b@localhost.localdomain>
References: <4201A382.1020208@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
In-Reply-To: <4201A382.1020208@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 03 Feb 2005 05:07:30 +0100
Christian Schmid <webmaster@rapidforum.com> wrote:

> Hi.
> 
> Your new dynamically adjusted socket-buffer in 2.6.10 is really a pain for big servers. PLEASE tell 
> me a way how to disable it.

sysctl -w net.ipv4.tcp_wmem="4096 8192 16384"

Your single stream will be slower, but the memory footprint will be smaller.
