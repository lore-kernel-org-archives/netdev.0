From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 2/2] usbnet & cdc-ether: Autosuspend for online devices
Date: Thu, 3 Dec 2009 22:59:12 +0100
Message-ID: <200912032259.12276.oliver@neukum.org>
References: <200912032241.43772.oliver@neukum.org> <20091203.134532.225926933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:42549 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbZLCV7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:59:01 -0500
In-Reply-To: <20091203.134532.225926933.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 3. Dezember 2009 22:45:32 schrieb David Miller:
 
> But this all might be due to some other changes I applied today and
> didn't push out yet to net-next-2.6, let me check on that for you.

This is the top of my tree.

	Regards
		Oliver

commit 17b97d1c24a061843a8f707e80f23a7b0b7647df
Author: Oliver Neukum <oliver@neukum.org>
Date:   Thu Dec 3 22:08:12 2009 +0100

    usbnet & cdc-ether: Autosuspend for online devices

    Using remote wakeup and delayed transmission to allow
    online device to go into usb autosuspend.
    Minimal alternate support for devices that don't support
    remote wakeup.

    Signed-off-by: Oliver Neukum <oliver@neukum.org>

commit b215603d7bbe3907666d27ebcd6ae847dd4f3a03
Author: Oliver Neukum <oliver@neukum.org>
Date:   Thu Dec 3 22:02:11 2009 +0100

    cdc-ether:Implement reset_resume()

    Normal resume can do double duty as reset_resume() for this driver
    as it keeps no state in the device

    Signed-off-by: Oliver Neukum <oliver@neukum.org>

commit 1f5865e73fb18834f52bd6e1d27bce86ff372089
Author: Shan Wei <shanwei@cn.fujitsu.com>
Date:   Wed Dec 2 15:39:04 2009 -0800

    ip: update the description of rp_filter in ip-sysctl.txt

    The commit 27fed4175acf81ddd91d9a4ee2fd298981f60295 (ip: fix logic of
    reverse path filter sysctl) has changed the logic of rp_filter.  The
    document about rp_filter is out of date. Now, setting
    conf/all/rp_filte with 0 can also enable source validation.

    Update the document according to the commit.

    Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
