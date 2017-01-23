From: Murali Karicheri <m-karicheri2@ti.com>
Subject: iproute2: using .maxattr = IFLA_VLAN_MAX??
Date: Mon, 23 Jan 2017 12:44:53 -0500
Message-ID: <58864115.4060608@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:53082 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750756AbdAWRpH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 12:45:07 -0500
Received: from dflxv15.itg.ti.com ([128.247.5.124])
        by fllnx209.ext.ti.com (8.15.1/8.15.1) with ESMTP id v0NHiufv012061
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 11:44:56 -0600
Received: from DFLE72.ent.ti.com (dfle72.ent.ti.com [128.247.5.109])
        by dflxv15.itg.ti.com (8.14.3/8.13.8) with ESMTP id v0NHipi4027475
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 11:44:51 -0600
Received: from [158.218.103.148] (ileax41-snat.itg.ti.com [10.172.224.153])     by
 dflp32.itg.ti.com (8.14.3/8.13.8) with ESMTP id v0NHioa8009855 for
 <netdev@vger.kernel.org>; Mon, 23 Jan 2017 11:44:50 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi iproute2 experts,

Found the below usage of IFLA_VLAN_MAX in ip/iplink_hsr.c

struct link_util hsr_link_util = {
        .id             = "hsr",
        .maxattr        = IFLA_VLAN_MAX, <==== should be IFLA_HSR_MAX
        .parse_opt      = hsr_parse_opt,
        .print_opt      = hsr_print_opt,
        .print_help     = hsr_print_help,
};

This appears to be a cut-n-paste bug as the source is based on 
ip/iplink_vlan.c and should be fixed to IFLA_HSR_MAX. If yes, 
I will send a patch for this.

Thanks.
-- 
Murali Karicheri
Linux Kernel, Keystone
