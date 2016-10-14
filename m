From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 2/2] ila: Cache a route to translated address
Date: Fri, 14 Oct 2016 11:04:02 +0200
Message-ID: <20161014110402.198d6579@griffin>
References: <20161014005743.288956-1-tom@herbertland.com>
        <20161014005743.288956-3-tom@herbertland.com>
        <58007996.2070500@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
        netdev@vger.kernel.org, kernel-team@fb.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45790 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750974AbcJNJEG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 05:04:06 -0400
In-Reply-To: <58007996.2070500@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Oct 2016 23:22:14 -0700, Roopa Prabhu wrote:
> This removes the last and only user of lwt orig_output. we can drop it
> subsequently. But since orig_input is still in use, probably better to keep it
> around for symmetry and for other uses in the future.

If it's no longer used, let's remove it. It can be always added later
again if needed. We don't keep things just because they maybe can be
used for something in the future.

Thanks,

 Jiri
