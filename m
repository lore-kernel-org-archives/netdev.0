From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 00/12] net: Convert vrf from dst to tx hook
Date: Wed, 31 Aug 2016 17:14:13 -0600
Message-ID: <eda9593c-69f8-6d90-05da-1505ba56bc33@cumulusnetworks.com>
References: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33305 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753364AbcHaXOR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 19:14:17 -0400
Received: by mail-pf0-f175.google.com with SMTP id g202so1036195pfb.0
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 16:14:17 -0700 (PDT)
In-Reply-To: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/30/16 11:34 AM, David Ahern wrote:
> This series fixes this problem by removing the output dst that points
> to the VRF and always doing the actual FIB lookup. This allows the real
> dst to be cached on sockets and used for MSS. Packets are diverted to
> the VRF device on Tx using an l3mdev hook in the output path similar to
> to what is done for Rx.

Dave:

please drop this series. BGP smoke tests triggered a couple of problems I need to resolve.
