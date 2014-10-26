From: Paul Barker <paul@paulbarker.me.uk>
Subject: [ethtool][PATCH] Fix build with musl libc
Date: Sun, 26 Oct 2014 11:44:08 +0000
Message-ID: <1414323849-5739-1-git-send-email-paul@paulbarker.me.uk>
Cc: Paul Barker <paul@paulbarker.me.uk>
To: Ben Hutchings <bwh@kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:54965 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbaJZLo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2014 07:44:27 -0400
Received: by mail-lb0-f179.google.com with SMTP id l4so4383192lbv.24
        for <netdev@vger.kernel.org>; Sun, 26 Oct 2014 04:44:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is taken from the Sabotage Linux distro which uses musl as the system
C library. It has also been successfully used within the OpenEmbedded build
system which supports glibc, uclibc and now musl. I'm submitting this on behalf
of the original patch author to save time.

It's a fairly simple change so it shouldn't cause any problems. However, I've
not submitted anything to ethtool or the kernel before so just let me know if
I've done something wrong and I'll try to fix it.

I'm not subscribed to netdev@ so please Cc me in any replies.

Paul Barker (1):
  Fix build with musl by using more common typedefs

 internal.h | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

-- 
2.1.2
