From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] net, TTY: initialize tty->driver_data before usage
Date: Fri, 5 Oct 2012 09:25:31 -0700
Message-ID: <20121005162531.GA15434@kroah.com>
References: <1349395281-12495-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: samuel@sortiz.org, davem@davemloft.net, jslaby@suse.cz,
	alan@linux.intel.com, levinsasha928@gmail.com, davej@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1349395281-12495-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 04, 2012 at 08:01:21PM -0400, Sasha Levin wrote:
> Commit 9c650ffc ("TTY: ircomm_tty, add tty install") split _open() to
> _install() and _open(). It also moved the initialization of driver_data
> out of open(), but never added it to install() - causing a NULL ptr
> deref whenever the driver was used.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> Acked-by: Jiri Slaby <jslaby@suse.cz>
> ---
>  net/irda/ircomm/ircomm_tty.c | 2 ++
>  1 file changed, 2 insertions(+)

Nice catch, now applied.

greg k-h
