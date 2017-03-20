From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] vxlan: use preferred address family when neither group
 or remote is specified
Date: Mon, 20 Mar 2017 10:18:02 -0700
Message-ID: <20170320101802.48844628@xeon-e3>
References: <20170309200542.24762-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
To: Vincent Bernat <vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35267 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755236AbdCTRSG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 13:18:06 -0400
Received: by mail-pg0-f42.google.com with SMTP id t143so14626983pgb.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 10:18:05 -0700 (PDT)
In-Reply-To: <20170309200542.24762-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  9 Mar 2017 21:05:42 +0100
Vincent Bernat <vincent@bernat.im> wrote:

> When neither group or remote is specified (or if they are specified with
> the any address), nothing is sent to the kernel. In this case, the
> kernel defaults to IPv4. This makes impossible to use IPv6 with
> unspecified unicast remote ("bridge fdb add" will return
> EAFNOTSUPPORT).
> 
> If the user specifies a preferred address family (eg, "ip -6 link add"),
> then send either IFLA_VXLAN_GROUP or IFLA_VXLAN_GROUP6 to enforce the
> use of the appropriate family.
> 
> Signed-off-by: Vincent Bernat <vincent@bernat.im>

Makes sense. Applied
