From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] NET: irda, remove unnecessary checks
Date: Sun, 10 Jan 2010 13:28:13 -0800 (PST)
Message-ID: <20100110.132813.21319484.davem@davemloft.net>
References: <1263114674-10433-1-git-send-email-jslaby@suse.cz>
	<1263122254-18781-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, alan@linux.intel.com, gregkh@suse.de,
	netdev@vger.kernel.org
To: jslaby@suse.cz
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753996Ab0AJV2J@vger.kernel.org>
In-Reply-To: <1263122254-18781-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jslaby@suse.cz>
Date: Sun, 10 Jan 2010 12:17:34 +0100

> Stanse found a potential null dereference in ircomm_tty_close
> and ircomm_tty_hangup. There is a check for tty being NULL,
> but it is dereferenced earlier. But it is bogus, the tty cannot
> be NULL, so remove the !tty checks.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>

Applied.
