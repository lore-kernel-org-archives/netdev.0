From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: use ethtool for link checking first
Date: Mon, 27 Apr 2009 02:57:55 -0700 (PDT)
Message-ID: <20090427.025755.256001384.davem@davemloft.net>
References: <20090424115823.GD16703@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46674
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757875AbZD0J6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 05:58:03 -0400
In-Reply-To: <20090424115823.GD16703@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 24 Apr 2009 13:58:23 +0200

> This patch only changes the order of interfaces to use for checking slave link
> status in bond_check_dev_link() to priorize ethtool interface. Should safe some
> troubles as ethtool seems to be more supported.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied to net-next-2.6
