From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/2] net: mpls: Delete route when all nexthops
 have been deleted
Date: Sun, 26 Mar 2017 10:26:05 -0700
Message-ID: <58D7F9AD.9080104@cumulusnetworks.com>
References: <1490394117-19268-1-git-send-email-dsa@cumulusnetworks.com> <1490394117-19268-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rshearma@brocade.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:32790 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751803AbdCZR0X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Mar 2017 13:26:23 -0400
Received: by mail-pg0-f47.google.com with SMTP id n5so10420672pgh.0
        for <netdev@vger.kernel.org>; Sun, 26 Mar 2017 10:26:10 -0700 (PDT)
In-Reply-To: <1490394117-19268-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/24/17, 3:21 PM, David Ahern wrote:
> When all devices for all nexthops in a route have been deleted, the
> route is effectively dead, so remove it.
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
