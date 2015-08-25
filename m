From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH 1/2] usbnet: Get EVENT_NO_RUNTIME_PM bit before it is
 cleared
Date: Tue, 25 Aug 2015 15:01:49 +0200
Message-ID: <1440507709.13824.6.camel@suse.com>
References: <55AD3A41.2040100@rosalab.ru>
	 <1440447223-15945-1-git-send-email-eugene.shatokhin@rosalab.ru>
	 <1440447223-15945-2-git-send-email-eugene.shatokhin@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440447223-15945-2-git-send-email-eugene.shatokhin@rosalab.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-08-24 at 23:13 +0300, Eugene Shatokhin wrote:
> It is needed to check EVENT_NO_RUNTIME_PM bit of dev->flags in
> usbnet_stop(), but its value should be read before it is cleared
> when dev->flags is set to 0.

Can we agree that this at least is good and should go upstream
and into stable?

	Regards
		Oliver
