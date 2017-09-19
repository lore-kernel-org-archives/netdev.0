From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [RFC PATCH 1/3] usbnet: Get rid of spammy usbnet "kevent X may
 have been dropped"
Date: Tue, 19 Sep 2017 22:36:02 +0200
Message-ID: <1505853362.15836.7.camel@suse.com>
References: <20170919161522.995-1-dianders@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: groeck@chromium.org, grundler@chromium.org,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
To: Douglas Anderson <dianders@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919161522.995-1-dianders@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, den 19.09.2017, 09:15 -0700 schrieb Douglas Anderson:
> 
> ALSO NOTE: If somehow some of the types of work need to be repeated if
> usbnet_defer_kevent() is called multiple times then that should be
> quite easy to accomplish without dropping any work on the floor.  We
> can just keep an atomic count for that type of work and add a loop
> into usbnet_deferred_kevent().

Thanks for doing this, it is overdue.

	Regards
		Oliver

> Signed-off-by: Douglas Anderson <dianders@chromium.org>
Acked-by: Oliver Neukum <oneukum@suse.com>
