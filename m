From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Fri, 2 Sep 2011 23:30:41 -0700
Message-ID: <20110902233041.30732b69@s6510.ftrdhcpuser.net>
References: <20110902172220.830228928@vyatta.com>
	<20110902172247.396753508@vyatta.com>
	<4E614CF7.7030700@gmail.com>
	<20110902151100.327af0bf@nehalam.ftrdhcpuser.net>
	<4E618DCD.5070901@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Achmad Basuki <abazh@sfc.wide.ad.jp>
To: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58508 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754153Ab1ICGao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Sep 2011 02:30:44 -0400
In-Reply-To: <4E618DCD.5070901@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 03 Sep 2011 11:15:41 +0900
Ang Way Chuang <wcang@sfc.wide.ad.jp> wrote:

> A more ideal solution in this case is to add the option to enabling carrier on sysfs and modify libvirtd
> to turn on the carrier if IPv6 is enabled. But it will still break the existing configuration until everyone
> upgrade to the latest libvirtd and kernel. Since there is no other complain from other user with this setup,
> I guess nobody actually assigns IPv6 to libvirtd network device at this moment (partly because virt-manager
> doesn't expose that functionality yet??).

Not sure about adding an option to support a configuration that is only available
by manually editing the xml files. There can't be that many people using libvirt in
this way, and fixing libvirt seems like a better solution.

Rather than rush in a kludge to handle this, let's take a few days and
examine what libvirt is trying to do and how it is doing it.
