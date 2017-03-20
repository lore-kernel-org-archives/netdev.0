From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip route: Add missing space between nexthop
 and via for mpls multipath routes
Date: Mon, 20 Mar 2017 10:15:20 -0700
Message-ID: <20170320101520.6d2851fa@xeon-e3>
References: <1489793954-10667-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35443 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754844AbdCTRsY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 13:48:24 -0400
Received: by mail-pg0-f54.google.com with SMTP id t143so15001862pgb.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 10:47:59 -0700 (PDT)
In-Reply-To: <1489793954-10667-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Mar 2017 16:39:14 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> MPLS multipath routes are missing a space between 'nexthop' and 'via':
> 
> $ ip -net ns1 -f mpls ro ls
> 100
> 	nexthopvia inet 172.16.2.2  dev virt12
> 	nexthopvia inet 172.16.3.2  dev br0
> 
> Add it.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied
