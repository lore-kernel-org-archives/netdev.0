From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: diag: make udp_diag_destroy work for mapped
 addresses.
Date: Wed, 7 Sep 2016 08:32:45 -0600
Message-ID: <d28639fd-2ab2-02f9-7a42-e483a919d22f@cumulusnetworks.com>
References: <1473223115-144755-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ek@google.com, eric.dumazet@gmail.com, davem@davemloft.net
To: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:35412 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757198AbcIGOcr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 10:32:47 -0400
Received: by mail-it0-f45.google.com with SMTP id e124so199970821ith.0
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 07:32:47 -0700 (PDT)
In-Reply-To: <1473223115-144755-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/6/16 10:38 PM, Lorenzo Colitti wrote:
> udp_diag_destroy does look up the IPv4 UDP hashtable for mapped
> addresses, but it gets the IPv4 address to look up from the
> beginning of the IPv6 address instead of the end.
> 
> Tested: https://android-review.googlesource.com/269874
> Fixes: 5d77dca82839 ("net: diag: support SOCK_DESTROY for UDP sockets")
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---
>  net/ipv4/udp_diag.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Acked-by: David Ahern <dsa@cumulusnetworks.com>
