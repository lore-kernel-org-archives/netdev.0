From: Andrei Warkentin <andreiw@motorola.com>
Subject: Always send NETDEV_CHANGEADDR up
Date: Thu,  4 Aug 2011 21:11:52 -0500
Message-ID: <1312510313-26300-1-git-send-email-andreiw@motorola.com>
References: <1312509349-23363-1-git-send-email-andreiw@motorola.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og101.obsmtp.com ([64.18.0.141]:49476 "EHLO
	exprod5og101.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754287Ab1HECSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 22:18:39 -0400
Received: from DE01MGRG01.AM.MOT-MOBILITY.COM ([10.176.130.20])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p752JOkU006536
	for <netdev@vger.kernel.org>; Thu, 4 Aug 2011 22:19:24 -0400 (EDT)
Received: from mail-iy0-f170.google.com (mail-iy0-f170.google.com [209.85.210.170])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p752C2Bm003871
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 4 Aug 2011 22:19:23 -0400 (EDT)
Received: by mail-iy0-f170.google.com with SMTP id 16so2720286iye.29
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2011 19:18:37 -0700 (PDT)
In-Reply-To: <1312509349-23363-1-git-send-email-andreiw@motorola.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor fix in br_notify, such that notification only is sent if 
bridge MAC address is updated.

ToC:
[PATCHv2] Bridge: Always send NETDEV_CHANGEADDR up on br MAC change.

A
