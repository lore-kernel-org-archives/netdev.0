From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile
Date: Mon, 26 Apr 2010 13:24:35 -0700 (PDT)
Message-ID: <20100426.132435.245397555.davem@davemloft.net>
References: <20100424.001934.189691704.davem@davemloft.net>
	<C7FB3747.2BAAA%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38141
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753145Ab0DZUYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 16:24:30 -0400
In-Reply-To: <C7FB3747.2BAAA%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Mon, 26 Apr 2010 12:27:51 -0700

> We'd need an array of struct ifla_vf_port_profile hanging off of netdev, one
> element for each VF.  That seems like a lot of mem hanging off of netdev,
> and we'd have to define a MAX_VF to size the array.  How about a
> ndo_get_vf_port_profile() that the netdev fills in, and the netdev keeps the
> data in it's private area?  That's how ndo_get_vf_config() is working.

Sure if the device can do it, but for situations where it can't we can
use a linked list and dynamic memory allocation.
