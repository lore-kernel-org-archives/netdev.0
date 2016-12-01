From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next iproute2 PATCH 2/2 v2] ss: Add inet raw sockets
 information gathering via netlink diag interface
Date: Thu, 1 Dec 2016 10:57:01 -0800
Message-ID: <20161201105701.1c54b258@xeon-e3>
References: <1478092496-7540-1-git-send-email-gorcunov@gmail.com>
        <1478092496-7540-3-git-send-email-gorcunov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avagin@openvz.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34031 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752008AbcLAS5E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 13:57:04 -0500
Received: by mail-pf0-f176.google.com with SMTP id c4so47525036pfb.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 10:57:03 -0800 (PST)
In-Reply-To: <1478092496-7540-3-git-send-email-gorcunov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  2 Nov 2016 16:14:56 +0300
Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> unix, tcp, udp[lite], packet, netlink sockets already support diag
> interface for their collection and killing. Implement support
> for raw sockets.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@gmail.com>

Applied both patches, but needed to remove inet_diag.h since
already updated kernel headers.
