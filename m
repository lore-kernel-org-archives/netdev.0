From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net v2 01/03] vxlan: only migrate dynamic FDB entries
Date: Mon, 10 Jun 2013 14:00:56 -0700 (PDT)
Message-ID: <20130610.140056.72026878450297366.davem@redhat.com>
References: <20130610195822.888424947@vyatta.com>
	<20130610131317.0c17ed0d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19396 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751638Ab3FJVA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 17:00:58 -0400
In-Reply-To: <20130610131317.0c17ed0d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 10 Jun 2013 13:13:17 -0700

> Only migrate dynamic forwarding table entries, don't modify
> static entries. If packet received from incorrect source IP address
> assume it is an imposter and drop it.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> ---
> Should go to -stable as well.

Applied and queued up for -stable.
