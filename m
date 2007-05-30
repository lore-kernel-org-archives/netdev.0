From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/7] cxgb3 - fix netpoll hanlder
Date: Tue, 29 May 2007 20:42:24 -0400
Message-ID: <465CC870.7050407@garzik.org>
References: <20070526225952.12115.30971.stgit@localhost.localdomain> <465B591B.1010507@garzik.org> <465CBE4B.9070009@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58114 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866AbXE3Am3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 20:42:29 -0400
In-Reply-To: <465CBE4B.9070009@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeremy Fitzhardinge wrote:
> Jeff Garzik wrote:
>>> +        t3_intr_handler(adapter, qs->rspq.polling) (0,
>>> +                    (adapter->flags & USING_MSIX) ?
>>> +                    (void *)qs : (void *)adapter);
>> Remove needless casts to void*
> The two branches of ?: need to have the same type; without the casts
> they'd be "struct sge_qset" and "struct adapter".  Seems a bit cruddy to
> have two types passed to one function depending on the MSI state, but
> maybe that's OK.

Look at the function argument...

	Jeff



