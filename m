From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] init_netdev missing locking
Date: Wed, 15 Oct 2003 22:33:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031015223318.597494ed.davem@redhat.com>
References: <20031015110520.0206e327.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org.sgi.com>
In-Reply-To: <20031015110520.0206e327.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Oct 2003 11:05:20 -0700
"Randy.Dunlap" <rddunlap@osdl.org> wrote:

> It looks like the call to dev_alloc_name() in init_netdev()
> isn't protected by the required locking.
> This patch adds rtnl_lock/unlock around the call to dev_alloc_name().
> 
> Comments?  or please apply.

Your fix is correct, so I've applied it.  Stephen is working to
deprecate the one thing that uses this function (init_etherdev()).

Please in the future properly root your patch, I had to fix this
one up before my automated scripts would eat it :)
