From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Thu, 4 Jun 2009 17:28:53 +0300
Message-ID: <15ddcffd0906040728k31a48ca2nc65e922ec23da5dd@mail.gmail.com>
References: <alpine.DEB.1.10.0906021044430.15692@gentwo.org>
	 <20090603.224104.222901210.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, rdreier@cisco.com, netdev@vger.kernel.org,
	yosefe@voltaire.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:21125 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755785AbZFDO2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 10:28:52 -0400
Received: by fg-out-1718.google.com with SMTP id 16so286469fgg.17
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2009 07:28:53 -0700 (PDT)
In-Reply-To: <20090603.224104.222901210.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 4, 2009 at 8:41 AM, David Miller <davem@davemloft.net> wrote:
> From: Christoph Lameter <cl@linux-foundation.org>

>> After this patch the socket queue will build up and the sender will be throttled

> I'm all for increasing those limits, but eliminating them I cannot agree with.

So the socket buffer reasoning isn't robust enough?

Or.
