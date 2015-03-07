From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/5] TTY: fix tty_wait_until_sent on 64-bit machines
Date: Sat, 7 Mar 2015 03:43:50 +0100
Message-ID: <20150307024350.GA7711@kroah.com>
References: <1425461947-15888-1-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jslaby@suse.cz>, Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Peter Hurley <peter@hurleysoftware.com>,
	Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-serial@vger.kernel.org,
	netdev@vger.kernel.org,
	ZIV-Asier Llano Palacios <asier.llano@cgglobal.com>
To: Johan Hovold <johan@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1425461947-15888-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 04, 2015 at 10:39:02AM +0100, Johan Hovold wrote:
> This series fixes an overflow bug in tty_wait_until_sent, which is
> currently broken on 64-bit machines for most TTY drivers (with
> serial-core being the notable exception).
> 
> The final patch makes the tty_wait_until_sent timeout a maximum one so
> that we actually honour the closing-wait timeout.
> 
> All but the second (clean-up) and final patch are marked for stable.
> 
> These patches are for v4.0 and I suggest Greg takes them all through the
> TTY tree.

Nice fixes, all now queued up.
