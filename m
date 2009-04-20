From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH net-next] myri10ge: allow per-board firmware overriding
Date: Mon, 20 Apr 2009 11:55:15 +0200
Message-ID: <49EC4683.3060605@myri.com>
References: <49E7239B.4000309@myri.com>	<20090417095038.49b745bf@dhcp-lab-109.englab.brq.redhat.com>	<49EA1DAC.1000602@myri.com>	<1240102617.5342.6.camel@obelisk.thedillows.org>	<1240108599.5342.11.camel@obelisk.thedillows.org> <20090420114041.37c7fa7b@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Dillow <dave@thedillows.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2006 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751473AbZDTJz3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 05:55:29 -0400
In-Reply-To: <20090420114041.37c7fa7b@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanislaw Gruszka wrote:
> Providing module_param_id would address this issues, but I have some concerns
> before doing it:
>
> - device have to access ID (like serial no) before initialization (at least
>   before driver will need parameter)
> - why nobody already done it - perhaps such thing would be totally useless
>   

Per-nic module parameters are used in some Intel NIC drivers but it's
not considered a very good solution in the general case:
   
http://kerneltrap.org/index.php?q=mailarchive/linux-netdev/2008/10/24/3801824/thread

But again, when talking about changing the NIC firmware, ethtool and
friends are not that easy.

Brice

