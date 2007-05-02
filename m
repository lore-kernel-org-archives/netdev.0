From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Virtual ethernet device (tunnel)
Date: Wed, 02 May 2007 08:49:52 -0400
Message-ID: <1178110192.4074.55.camel@localhost>
References: <46386DFB.7090109@sw.ru>  <46388562.9050305@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelianov <xemul@sw.ru>, David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Kirill Korotaev <dev@sw.ru>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, devel@openvz.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:10411 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993092AbXEBMt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 08:49:56 -0400
Received: by wx-out-0506.google.com with SMTP id h31so106369wxd
        for <netdev@vger.kernel.org>; Wed, 02 May 2007 05:49:55 -0700 (PDT)
In-Reply-To: <46388562.9050305@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-02-05 at 14:34 +0200, Patrick McHardy wrote:

> Thats a lot better than using sysfs, but I think it would be
> preferrable to use rtnetlink instead of genetlink for network
> configuration.

or you can just hold rtnl while using genl.
I do agree it would be easier to just use rtnetlink ...

cheers,
jamal


