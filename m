From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH] xen-netfront: rearrange netfront_info structure to separate
 tx and rx
Date: Tue, 09 Oct 2007 18:03:30 -0700
Message-ID: <470C24E2.7080009@goop.org>
References: <470BCC1D.4080007@goop.org> <470C20E9.9050405@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keir Fraser <Keir.Fraser@cl.cam.ac.uk>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:54373 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753314AbXJJBEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 21:04:14 -0400
In-Reply-To: <470C20E9.9050405@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Jeremy Fitzhardinge wrote:
>> Keep tx and rx elements separate on different cachelines to prevent
>> bouncing.
>>
>> Signed-off-by: Jeremy Fitzhardinge <jeremy@xensource.com>
>> Cc: Stephen Hemminger <shemminger@linux-foundation.org>
>> Cc: Christoph Hellwig <hch@infradead.org>
>>
>> ---
>>  drivers/net/xen-netfront.c |   37 ++++++++++++++++++-------------------
>>  1 file changed, 18 insertions(+), 19 deletions(-)
>
> ACK but does not apply to jgarzik/netdev-2.6.git#upstream nor
> davem/net-2.6.24.git 

Oh, OK, I'll have a look.  I wasn't aware of any other changes in
xen-netfront.  Or rather, there are a couple of other changes which I
think you already have: one to use the common netdev stats structure,
and another to remove a chunk of dead code.

    J
