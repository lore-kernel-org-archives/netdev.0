From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Who's allowed to set a skb destructor?
Date: Thu, 5 Jul 2007 15:07:22 +0200
Message-ID: <20070705130722.GB24731@one.firstfloor.org>
References: <468B54A6.5090902@ens-lyon.org> <p733b032mec.fsf@bingen.suse.de> <468CD0DB.8060705@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Brice Goglin <Brice.Goglin@ens-lyon.org>,
	netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:46190 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758574AbXGENHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 09:07:23 -0400
Content-Disposition: inline
In-Reply-To: <468CD0DB.8060705@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The destructor method is set and used for skbs originating from the RDMA 
> driver sitting above cxgb3.

If these skbs never reach the normal sockets based stack it might be ok.

-Andi
