From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/2] net/sched: cls_flower: Support matching on
 ARP
Date: Wed, 11 Jan 2017 14:27:10 +0100
Message-ID: <20170111132710.GJ1852@nanopsycho>
References: <1484139943-18199-1-git-send-email-simon.horman@netronome.com>
 <1484139943-18199-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33818 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966554AbdAKN1N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 08:27:13 -0500
Received: by mail-wm0-f67.google.com with SMTP id c85so36518711wmi.1
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 05:27:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1484139943-18199-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jan 11, 2017 at 02:05:43PM CET, simon.horman@netronome.com wrote:
>Support matching on ARP operation, and hardware and protocol addresses
>for Ethernet hardware and IPv4 protocol addresses.
>
>Example usage:
>
>tc qdisc add dev eth0 ingress
>
>tc filter add dev eth0 protocol arp parent ffff: flower indev eth0 \
>	arp_op request arp_sip 10.0.0.1 action drop
>tc filter add dev eth0 protocol rarp parent ffff: flower indev eth0 \
>	arp_op reply arp_tha 52:54:3f:00:00:00/24 action drop
>
>Signed-off-by: Simon Horman <simon.horman@netronome.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
