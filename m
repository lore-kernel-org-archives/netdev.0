From: "David S. Miller" <davem@redhat.com>
Subject: Re: The recent free_netdev() conversion...
Date: Mon, 1 Sep 2003 07:53:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901075345.4c35e3e6.davem@redhat.com>
References: <3F535EBD.6090401@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F535EBD.6090401@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 01 Sep 2003 10:59:09 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

>      err_out:
> 	kfree(dev);
 ...
> The "kfree" needs to be a free_netdev() too.

If the 'dev' hasn't been given to register_netdev() it
really doesn't need to be free_netdev().  It's just memory
until it has been given to the device layer.
