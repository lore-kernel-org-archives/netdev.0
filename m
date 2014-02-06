From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH iproute2 0/3] Support for tcp-metrics source address
Date: Thu,  6 Feb 2014 23:15:01 +0100
Message-ID: <1391724904-30504-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:36285 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223AbaBFWPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 17:15:19 -0500
Received: by mail-ea0-f171.google.com with SMTP id f15so1190203eak.16
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 14:15:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset implements support for showing and deleting tcp-metrics
based on the source-address.

Christoph Paasch (3):
  tcp_metrics: Rename addr to daddr and add local variable
  tcp_metrics: Display source-address
  tcp_metrics: Allow removal based on the source-IP

 include/linux/tcp_metrics.h |   2 +
 ip/tcp_metrics.c            | 154 +++++++++++++++++++++++++++++++-------------
 2 files changed, 111 insertions(+), 45 deletions(-)

-- 
1.8.3.2
