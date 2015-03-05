From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: [PATCH 5/5] TTY: fix tty_wait_until_sent maximum timeout
Date: Thu, 05 Mar 2015 09:32:25 -0500
Message-ID: <54F868F9.1050804@hurleysoftware.com>
References: <1425461947-15888-1-git-send-email-johan@kernel.org> <1425461947-15888-6-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jslaby@suse.cz>, Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-serial@vger.kernel.org,
	netdev@vger.kernel.org,
	ZIV-Asier Llano Palacios <asier.llano@cgglobal.com>
To: Johan Hovold <johan@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425461947-15888-6-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/04/2015 04:39 AM, Johan Hovold wrote:
> Currently tty_wait_until_sent may take up to twice as long as the
> requested timeout while waiting for driver and hardware buffers to
> drain.
> 
> Fix this by taking the remaining number of jiffies after waiting for
> driver buffers to drain into account so that the timeout actually
> becomes a maximum timeout as it is documented to be.
> 
> Note that this specifically implies tighter timings when closing a port
> as a consequence of actually honouring the port closing-wait setting
> for drivers relying on tty_wait_until_sent_from_close (e.g. via
> tty_port_close_start).

Reviewed-by: Peter Hurley <peter@hurleysoftware.com>
