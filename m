From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/3] net: ipv6: Allow shorthand delete of all
 nexthops in multipath route
Date: Mon, 16 Jan 2017 08:58:39 -0700
Message-ID: <7a47c420-0c35-4877-f618-8ca85d3dc5c6@cumulusnetworks.com>
References: <1484510826-2723-1-git-send-email-dsa@cumulusnetworks.com>
 <1484510826-2723-2-git-send-email-dsa@cumulusnetworks.com>
 <587CEB67.3040807@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34195 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750826AbdAPP6m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 10:58:42 -0500
Received: by mail-pf0-f180.google.com with SMTP id e4so16005263pfg.1
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 07:58:42 -0800 (PST)
In-Reply-To: <587CEB67.3040807@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/16/17 8:48 AM, Roopa Prabhu wrote:
> Do we really need the flag ?. It seems like delete with just prefix should delete all the routes in a multipath
> route by default... (understand that you have it there to preserve existing behavior...for people who maybe relying on it. But this seems more like a bug fix. route replace went through a few such bug fixes "ipv6: fix ECMP route replacement"). ok with either approach.

I'm fine dropping the flag for this patch and just deleting the entire route. The flag only exists because this patch changes behavior visible to the user.
