From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 06/24] TTY: ircomm, revamp locking
Date: Mon, 4 Jun 2012 17:57:49 +0100
Message-ID: <20120604175749.3995aa07@pyramind.ukuu.org.uk>
References: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
	<1338809738-18967-7-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, alan@linux.intel.com,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338809738-18967-7-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon,  4 Jun 2012 13:35:20 +0200
Jiri Slaby <jslaby@suse.cz> wrote:

> Use self->spinlock only for ctrl_skb and tx_skb. TTY stuff is now
> protected by tty_port->lock. This is needed for further cleanup (and
> conversion to tty_port helpers).
> 
> This also closes the race in the end of close.

Ah ok.. fixed here
