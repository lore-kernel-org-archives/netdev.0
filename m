From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: ipv6: send unsolicited NA on admin up
Date: Thu, 13 Apr 2017 13:45:44 +0200
Message-ID: <1492083944.2160091.943541576.3F765BD2@webmail.messagingengine.com>
References: <1492022944-18842-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:50754 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751473AbdDMLpp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 07:45:45 -0400
In-Reply-To: <1492022944-18842-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, Apr 12, 2017, at 20:49, David Ahern wrote:
> ndisc_notify is the ipv6 equivalent to arp_notify. When arp_notify is
> set to 1, gratuitous arp requests are sent when the device is brought up.
> The same is expected when ndisc_notify is set to 1 (per ndisc_notify in
> Documentation/networking/ip-sysctl.txt). The NA is not sent on NETDEV_UP
> event; add it.
> 
> Fixes: 5cb04436eef6 ("ipv6: add knob to send unsolicited ND on link-layer
> address change")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

In future we might be able to make this a bit more robust when DAD is
happening at the same time.

Thanks,
Hannes
