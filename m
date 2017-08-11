From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 1/2] mpls: add handlers
Date: Fri, 11 Aug 2017 14:34:05 +0200
Message-ID: <20170811123405.GY773745@eidolon>
References: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
 <1502396917-14848-2-git-send-email-amine.kherbouche@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        David Lamparter <equinox@diac24.net>
To: Amine Kherbouche <amine.kherbouche@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:56190 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752951AbdHKMrP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 08:47:15 -0400
Content-Disposition: inline
In-Reply-To: <1502396917-14848-2-git-send-email-amine.kherbouche@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 10, 2017 at 10:28:36PM +0200, Amine Kherbouche wrote:
> Mpls handler allows creation/deletion of mpls routes without using
> rtnetlink. When an incoming mpls packet matches this route, the saved
> function handler is called.

Since I originally authored this patch, I have come to believe that it
might be unneccessarily complicated.  It is unlikely that a lot of
different "handlers" will exist here;  the only things I can think of
are VPLS support and BIER-MPLS multicast replication.  I'm not saying
it's a bad idea, but, well, this was in the README that I gave to 6WIND
with this code:

...
MPLS layer:
- the "MPT_HANDLER" thing is probably overkill, it likely makes more sense to
  tie in the VPLS code more directly.
...


-David
