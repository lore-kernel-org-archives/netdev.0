From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 04/24] TTY: ircomm, use open counts from tty_port
Date: Mon, 4 Jun 2012 17:36:13 +0100
Message-ID: <20120604173613.5a75c451@pyramind.ukuu.org.uk>
References: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
	<1338809738-18967-5-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, alan@linux.intel.com,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338809738-18967-5-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon,  4 Jun 2012 13:35:18 +0200
Jiri Slaby <jslaby@suse.cz> wrote:

> Switch to tty_port->count and blocked_open.

Only question here is tty_port->count should be under the port lock, so
code which plays with the count itself like this probably needs to be
using the port lock ?

Alan
