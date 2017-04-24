From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: bridge: suppress broadcast when multicast flood is
 disabled
Date: Mon, 24 Apr 2017 12:00:35 -0700
Message-ID: <20170424120035.053b0a28@xeon-e3>
References: <1493042944-4005-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Mike Manning <mmanning@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33060 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966095AbdDXTAn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 15:00:43 -0400
Received: by mail-pf0-f171.google.com with SMTP id a188so16575614pfa.0
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 12:00:43 -0700 (PDT)
In-Reply-To: <1493042944-4005-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Apr 2017 15:09:04 +0100
Mike Manning <mmanning@brocade.com> wrote:

> Flood suppression for packets that are not unicast needs to be handled
> consistently by also not flooding broadcast packets. As broadcast is a
> special case of multicast, the same kernel parameter should be used to
> suppress flooding for both of these packet types.
> 
> Fixes: b6cb5ac8331b ("net: bridge: add per-port multicast flood flag")
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> ---

Makes sense.

Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
