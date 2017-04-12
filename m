From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net-next v1 1/1] L2TP device MTU setup - tunnel socket
 needs a lock
Date: Wed, 12 Apr 2017 09:53:55 +0200
Message-ID: <20170412075355.mjgaerruslswcjmw@alphalink.fr>
References: <alpine.DEB.2.11.1704112010410.8819@nelson51.eng.vyatta.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kleptog@svana.org, jchapman@katalix.com,
        davem@redhat.com, nprachan@brocade.com, rshearma@brocade.com,
        stephen@networkplumber.org, sdietric@brocade.com,
        ciwillia@brocade.com, lboccass@brocade.com, dfawcus@brocade.com,
        bhong@brocade.com, jblunck@brocade.com,
        linux-kernel@vger.kernel.org
To: "R. Parameswaran" <parameswaran.r7@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:60630 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751079AbdDLHx7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 03:53:59 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1704112010410.8819@nelson51.eng.vyatta.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 11, 2017 at 08:14:37PM -0700, R. Parameswaran wrote:
> 
> The MTU overhead calculation in L2TP device set-up
> merged via commit b784e7ebfce8cfb16c6f95e14e8532d0768ab7ff
> needs to be adjusted to lock the tunnel socket while
> referencing the sub-data structures to derive the
> socket's IP overhead.

Thanks.

Tested-by: Guillaume Nault <g.nault@alphalink.fr>

BTW, you don't need to add "v1" for the first version of a patch.
There's also no need for numbering pathes when there's only one in the
series. And we normally prefix the commit message with "<subsystem>: ".
For this patch, your subject would look like " [PATCH net-next] l2tp: ...".

Also, you could have added a "Reported-by:" tag (I don't really mind
in this case, but that's good practice).
