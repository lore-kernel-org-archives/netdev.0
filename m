From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 v2 0/2] add support for IFA_F_MANAGETEMPADDR
Date: Thu,  2 Jan 2014 16:34:37 +0100
Message-ID: <1388676879-2603-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, thaller@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:35467 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbaABPeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 10:34:46 -0500
Received: by mail-ee0-f52.google.com with SMTP id d17so6328212eek.39
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 07:34:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1->v2: Removed 0xff masking of ifa_flags

Jiri Pirko (2):
  add support for extended ifa_flags
  add support for IFA_F_MANAGETEMPADDR

 include/linux/if_addr.h |  2 ++
 ip/ipaddress.c          | 50 +++++++++++++++++++++++++++++++++++--------------
 2 files changed, 38 insertions(+), 14 deletions(-)

-- 
1.8.3.1
