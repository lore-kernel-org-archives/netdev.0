From: Andrew Morton <akpm@digeo.com>
Subject: Re: [2.5.66-mm3+debug] traces.
Date: Fri, 4 Apr 2003 18:14:27 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030404181427.5cf0c127.akpm@digeo.com>
References: <20030404172927.2b449167.akpm@digeo.com>
	<20030404.173538.03688224.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030404.173538.03688224.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@redhat.com> wrote:
>
> You simply cannot take BH locks inside of IRQ disabling
> ones, this is true 2.4.x too it just doesn't BUG() on you there
> (you get a potential deadlock instead).

I don't recall seeing a description or discussion of this deadlock.  Any
pointers?

> This patch should go through the Tulip maintainer (Jeff I guess)
> especially since it's a fix that belongs in 2.4.x as well.

Yup, I'll spam Jeff.
