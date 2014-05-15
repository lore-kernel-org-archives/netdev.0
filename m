From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 0/3] iproute2: ipa: show port id
Date: Thu, 15 May 2014 15:10:19 +0200
Message-ID: <1400159422-11797-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, mschmidt@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:43420 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725AbaEONK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 09:10:28 -0400
Received: by mail-lb0-f182.google.com with SMTP id z11so550347lbi.13
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 06:10:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The port id is in kernel for some while. Make is available for ip user.

Jiri Pirko (3):
  iproute2: arpd: use ll_addr_a2n and ll_addr_n2a
  iproute2: utils: change hexstring_n2a and hexstring_a2n to do not work
    with ":"
  iproute2: ipa: show port id

 ip/ipaddress.c |  8 ++++++++
 lib/utils.c    | 46 +++++++++++++---------------------------------
 misc/arpd.c    |  6 +++---
 3 files changed, 24 insertions(+), 36 deletions(-)

-- 
1.9.0
