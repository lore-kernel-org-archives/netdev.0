From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Fri, 17 Jul 2009 15:47:38 +0200
Message-ID: <200907171547.39815.oliver@neukum.org>
References: <1247824566-9141-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:50715 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934656AbZGQNrU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 09:47:20 -0400
In-Reply-To: <1247824566-9141-1-git-send-email-remi.denis-courmont@nokia.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 17. Juli 2009 11:56:06 schrieb R=C3=A9mi Denis-Courmont:
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0atomic_dec(&pnd->tx_queue)=
;
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0netif_wake_queue(dev);

Now that I think about it this seems to be a race condition.
What makes sure that your are still below the limit when you
wake the queue?

	Regards
		Oliver


