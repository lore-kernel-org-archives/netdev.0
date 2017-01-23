From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv6: Check that idev is non-NULL in
 rt6_fill_node
Date: Sun, 22 Jan 2017 21:37:40 -0700
Message-ID: <92bad931-3028-4c95-2028-f52596439b77@cumulusnetworks.com>
References: <1485144480-4460-1-git-send-email-dsa@cumulusnetworks.com>
 <20170122.233239.720617884825007357.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaolong.ye@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35075 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750747AbdAWEhm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 23:37:42 -0500
Received: by mail-pf0-f176.google.com with SMTP id f144so37851639pfa.2
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 20:37:42 -0800 (PST)
In-Reply-To: <20170122.233239.720617884825007357.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/22/17 9:32 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Sun, 22 Jan 2017 20:08:00 -0800
> 
>> The ipv6 route dump code passes ip6_null_entry to rt6_fill_node.
> 
> Doesn't this fact cause you to take a pause?

yes, it did.

> 
> I can't see a legitimate reason to dump the null entry, it's
> a marker rather than a real entry.
> 

neither do I. I was rather surprised to see it hit rt6_fill_node and that the rc is 0.

I can send a v2 that drops null_entry.
