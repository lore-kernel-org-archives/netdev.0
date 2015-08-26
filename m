From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] usbnet: Get EVENT_NO_RUNTIME_PM bit before it is
 cleared
Date: Tue, 25 Aug 2015 19:44:51 -0700 (PDT)
Message-ID: <20150825.194451.2234851257466313782.davem@davemloft.net>
References: <55AD3A41.2040100@rosalab.ru>
	<1440447223-15945-1-git-send-email-eugene.shatokhin@rosalab.ru>
	<1440447223-15945-2-git-send-email-eugene.shatokhin@rosalab.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oneukum@suse.de, bjorn@mork.no, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: eugene.shatokhin@rosalab.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440447223-15945-2-git-send-email-eugene.shatokhin@rosalab.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Date: Mon, 24 Aug 2015 23:13:42 +0300

> It is needed to check EVENT_NO_RUNTIME_PM bit of dev->flags in
> usbnet_stop(), but its value should be read before it is cleared
> when dev->flags is set to 0.
> 
> The problem was spotted and the fix was provided by
> Oliver Neukum <oneukum@suse.de>.
> 
> Signed-off-by: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>

Applied and queued up for -stable.
