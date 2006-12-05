From: Brice Goglin <Brice.Goglin@ens-lyon.org>
Subject: Re: [PATCH  v2 04/13] Connection Manager
Date: Tue, 05 Dec 2006 11:45:55 +0100
Message-ID: <45754DE3.1020505@ens-lyon.org>
References: <20061202224917.27014.15424.stgit@dell3.ogc.int>	 <20061202224958.27014.65970.stgit@dell3.ogc.int>	 <20061204110825.GA26251@2ka.mipt.ru>  <ada8xhnk6kv.fsf@cisco.com> <1165249251.32724.26.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from iona.labri.fr ([147.210.8.143]:51732 "EHLO iona.labri.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937501AbWLEKqI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 05:46:08 -0500
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <1165249251.32724.26.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
> There is no SW TCP stack in this driver.  The HW supports RDMA over
> TCP/IP/10GbE in HW and this is required for zero-copy RDMA over Ethernet
> (aka iWARP).  The device is a 10 GbE device, not Infiniband.

Then, I wonder why the driver goes in drivers/infiniband/ :)

Is there really no way to only keep the actual hw infiniband there, move
iwarp/rdma drivers in drivers/net/something/ and the core stuff in
net/something/ ?

Brice

