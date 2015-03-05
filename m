From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: [PATCH 2/5] TTY: bfin_jtag_comm: remove incorrect wait_until_sent
 operation
Date: Thu, 05 Mar 2015 09:33:30 -0500
Message-ID: <54F8693A.3050404@hurleysoftware.com>
References: <1425461947-15888-1-git-send-email-johan@kernel.org> <1425461947-15888-3-git-send-email-johan@kernel.org>
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
In-Reply-To: <1425461947-15888-3-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/04/2015 04:39 AM, Johan Hovold wrote:
> Remove incorrect and redundant wait_until_sent operation, which waits
> for the driver buffer rather than any hardware buffers to drain,
> something which is already taken care of by the tty layer (and
> chars_in_buffer).

Reviewed-by: Peter Hurley <peter@hurleysoftware.com>
