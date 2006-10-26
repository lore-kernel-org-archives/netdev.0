From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: setsockopt congestion control autoload
Date: Thu, 26 Oct 2006 13:55:47 -0700 (PDT)
Message-ID: <20061026.135547.88476649.davem@davemloft.net>
References: <20061026052253.GA10188@2ka.mipt.ru>
	<4540C791.5060200@osdl.org>
	<20061026145712.GA11062@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:65465
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423642AbWJZUzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 16:55:46 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20061026145712.GA11062@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 26 Oct 2006 18:57:13 +0400

> It just calls /sbin/modprobe, which in turn runs tons of scripts in
> /etc/hotplug, modprobe and other places...
> In the paranoid case we should not allow any user to load kernel
> modules, even known ones. Should this option be guarded by some
> capability check?

Do you realize that sys_socket() already makes this kind of
thing happen already?
