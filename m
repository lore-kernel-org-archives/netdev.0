From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH 3/4] vxlan: Enforce IP ID verification on outer headers
Date: Mon, 7 Mar 2016 20:05:20 +0200
Message-ID: <CAJ3xEMgpiaaLJrSqefOgrDVXsyKDtqSYQ7O01jq_UYp+UeT4bg@mail.gmail.com>
References: <20160307172201.5295.69740.stgit@localhost.localdomain>
	<20160307172214.5295.52624.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:35623 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbcCGSFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 13:05:21 -0500
Received: by mail-ig0-f194.google.com with SMTP id ww10so742537igb.2
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 10:05:21 -0800 (PST)
In-Reply-To: <20160307172214.5295.52624.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 7, 2016 at 7:22 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This change enforces the IP ID verification on outer headers.  As a result
> if the DF flag is not set on the outer header we will force the flow to be
> flushed in the event that the IP ID is out of sequence with the existing
> flow.

Can you please state the precise requirement for aggregation w.r.t IP
IDs here? and point to where/how this is enforced, e.g for
non-tunneled TCP GRO-ing?

Or.
