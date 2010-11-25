From: Sergey Lapin <slapin@ossfans.org>
Subject: Re: [PATCH 1/1] NET: wan/x25_asy, move lapb_unregister to
 x25_asy_close_tty
Date: Thu, 25 Nov 2010 17:56:59 -0500
Message-ID: <20101125225659.GA13807@build.ihdev.net>
References: <1290642894-4577-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	Andrew Hendry <andrew.hendry@gmail.com>,
	Mikhail Ulyanov <ulyanov.mikhail@gmail.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1290642894-4577-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 25, 2010 at 12:54:54AM +0100, Jiri Slaby wrote:
> We register lapb when tty is created, but unregister it only when the
> device is UP. So move the lapb_unregister to x25_asy_close_tty after
> the device is down.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Reported-by: Sergey Lapin <slapin@ossfans.org>
> Cc: Andrew Hendry <andrew.hendry@gmail.com>
Tested-by: Sergey Lapin <slapin@ossfans.org>
Tested-by: Mikhail Ulyanov <ulyanov.mikhail@gmail.com>
