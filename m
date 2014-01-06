From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 v3 0/2] add support for IFA_F_MANAGETEMPADDR
Date: Mon,  6 Jan 2014 10:17:08 +0100
Message-ID: <1388999830-1753-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, thaller@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:38006 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292AbaAFJRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 04:17:14 -0500
Received: by mail-ee0-f43.google.com with SMTP id c13so7699903eek.16
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 01:17:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1->v2: Removed 0xff masking of ifa_flags
v2->v3: Incorporated changes that Thomas suggested

Jiri Pirko (2):
  add support for extended ifa_flags
  add support for IFA_F_MANAGETEMPADDR

 include/linux/if_addr.h |  2 ++
 ip/ipaddress.c          | 55 +++++++++++++++++++++++++++++++++++--------------
 2 files changed, 42 insertions(+), 15 deletions(-)

-- 
1.8.3.1
