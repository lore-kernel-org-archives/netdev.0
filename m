From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] tun: add device name(iff) field to proc fdinfo entry
Date: Tue, 28 Jan 2014 23:47:56 -0800 (PST)
Message-ID: <20140128.234756.2149865523675021687.davem@davemloft.net>
References: <20140128.231947.1827551289841225189.davem@davemloft.net>
	<1390981411-16146-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yamato@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49342 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbaA2Hr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 02:47:57 -0500
In-Reply-To: <1390981411-16146-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masatake YAMATO <yamato@redhat.com>
Date: Wed, 29 Jan 2014 16:43:31 +0900

> A file descriptor opened for /dev/net/tun and a tun device are
> connected with ioctl.  Though understanding the connection is
> important for trouble shooting, no way is given to a user to know
> the connected device for a given file descriptor at userland.
> 
> This patch adds a new fdinfo field for the device name connected to
> a file descriptor opened for /dev/net/tun.
> 
> Here is an example of the field:
...
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>

This looks a lot better, applied, thanks.
