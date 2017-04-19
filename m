From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net: ipv6: send unsolicited NA if enabled for
 all interfaces
Date: Wed, 19 Apr 2017 22:30:32 +0300
Message-ID: <a6a987ee-e9c4-1a11-1d81-8806c02b42f5@cogentembedded.com>
References: <1492628736-26696-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:36507 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763667AbdDSTag (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 15:30:36 -0400
Received: by mail-lf0-f41.google.com with SMTP id c80so17795445lfh.3
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 12:30:35 -0700 (PDT)
In-Reply-To: <1492628736-26696-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 04/19/2017 10:05 PM, David Ahern wrote:

> When arp_notify is set to 1 for either a specific interface or for 'all'
> interfaces, gratuitous arp requests are sent. Since ndisc_notify is the
> ipv6 equivalent to arp_notify, it should follow the same semantics.
> Commit 4a6e3c5def13 sends the NA on admin up. The final piece is checking

    Need to also specify the commit summary line enclosed into (""), just like 
below.

> devconf_all->ndisc_notify in addition to the per device setting. Add it.
>
> Fixes: 5cb04436eef6 ("ipv6: add knob to send unsolicited ND on link-layer address change")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
[...]

MBR, Sergei
