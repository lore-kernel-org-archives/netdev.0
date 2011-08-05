From: Andrei Warkentin <andreiw@motorola.com>
Subject: Fix bridge MAC change notification.
Date: Thu,  4 Aug 2011 20:55:48 -0500
Message-ID: <1312509349-23363-1-git-send-email-andreiw@motorola.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5ob111.obsmtp.com ([64.18.0.21]:41356 "EHLO
	exprod5ob111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082Ab1HERD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 13:03:56 -0400
Received: from DE01MGRG01.AM.MOT-MOBILITY.COM ([10.176.129.42])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p7523Og8000348
	for <netdev@vger.kernel.org>; Thu, 4 Aug 2011 22:03:24 -0400 (EDT)
Received: from mail-yi0-f42.google.com (mail-yi0-f42.google.com [209.85.218.42])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p75230T0000217
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 4 Aug 2011 22:03:23 -0400 (EDT)
Received: by mail-yi0-f42.google.com with SMTP id 19so283781yie.15
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2011 19:02:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is my first time on netdev. I am writing about the ensuring
that upper network layers are aware of bridge MAC changes due
to re-configuration or port addition/removal.

It seems this topic has cropped up before, with one patch by 
Stephen Hemminger already in 3.0, and a fix for it (sent 7/22)
(http://marc.info/?l=linux-netdev&m=131135705613958&w=2) pending.

The existing patches don't cover the br_del_if case, the case of 
a changing MAC address on a port associated with the bridge, and
the case of manually setting the MAC address, which the following
patch remedies.

Table of Contents:
[PATCH] Bridge: Always send NETDEV_CHANGEADDR up on br MAC change.

Thank you,
A

