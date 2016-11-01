From: Murali Karicheri <m-karicheri2@ti.com>
Subject: SNMP read-write MIBs
Date: Tue, 1 Nov 2016 14:06:40 -0400
Message-ID: <5818D9B0.60907@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:47951 "EHLO
        devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751389AbcKASGh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 14:06:37 -0400
Received: from dflxv15.itg.ti.com ([128.247.5.124])
        by devils.ext.ti.com (8.13.7/8.13.7) with ESMTP id uA1I6ac1018018
        for <netdev@vger.kernel.org>; Tue, 1 Nov 2016 13:06:36 -0500
Received: from DLEE71.ent.ti.com (dlee71.ent.ti.com [157.170.170.114])
        by dflxv15.itg.ti.com (8.14.3/8.13.8) with ESMTP id uA1I6asS014636
        for <netdev@vger.kernel.org>; Tue, 1 Nov 2016 13:06:36 -0500
Received: from [158.218.103.164] (ileax41-snat.itg.ti.com [10.172.224.153])     by
 dlep33.itg.ti.com (8.14.3/8.13.8) with ESMTP id uA1I6amE023406 for
 <netdev@vger.kernel.org>; Tue, 1 Nov 2016 13:06:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello netdev experts,

I am investigating the requirements to support hsr/prp SNMP functions in kernel.
Based on my investigation so far, the kernel include file include/net/snmp.h
defines all of the SNMP MIBS related defines and structures. But the MIBs are
read-only type MIBs. Is there any implementation of read-write MIBs in kernel?

One of the specs for MIBs that are investigating have read-write MIBs and
wondering if we have any precedence of such MIBs implemented in kernel space.
If not, what is the suggested way to implement these MIBs in kernel space?

I assume that to implement read-only MIBs for hsr driver, I need to add
them to snmp.h and use standard Macros in snmp.h to update them from the driver.

Thanks
 
Murali Karicheri
Linux Kernel, Keystone
