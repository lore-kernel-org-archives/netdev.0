From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 3/5] bridge: uapi: add per vlan tunnel info
Date: Sat, 21 Jan 2017 08:59:25 -0800
Message-ID: <5883936D.5090600@cumulusnetworks.com>
References: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com> <1484977616-1541-4-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33179 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdAUQ7Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 11:59:25 -0500
Received: by mail-pg0-f42.google.com with SMTP id 204so32316753pge.0
        for <netdev@vger.kernel.org>; Sat, 21 Jan 2017 08:59:25 -0800 (PST)
In-Reply-To: <1484977616-1541-4-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/20/17, 9:46 PM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> New netlink api to associate tunnel info per vlan.
> This is used by bridge driver to send tunnel metadata to
> bridge ports in LWT tunnel dst metadata mode.
>
> One example use for this is a vxlan bridging gateway or vtep
> which maps vlans to vn-segments (or vnis). User can configure
> per-vlan tunnel information which the bridge driver can use
> to bridge vlan into the corresponding vn-segment.
>
> This patch also introduces a bridge port flag IFLA_BRPORT_LWT_VLAN
> to enable this feature on a tunnel bridge port. It is off by default.
>
>
since it does not use the LWT infra, I plan to drop any LWT references and call
the new features and modes plain collect metadata or dst_metadata mode in the next version.
