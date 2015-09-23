From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip: allow using a device "help" (or a prefix thereof)
Date: Wed, 23 Sep 2015 16:07:02 -0700
Message-ID: <20150923160702.08b62a84@urahara>
References: <55FBCA11.7070604@kristov.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Wilhelm Wijkander <lists@0x5e.se>,
	Vadim Kochan <vadim4j@gmail.com>,
	Leonhard Preis <leonhard@pre.is>
To: Christoph Schulz <develop@kristov.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35252 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755037AbbIWXGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 19:06:51 -0400
Received: by pacfv12 with SMTP id fv12so53973229pac.2
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 16:06:51 -0700 (PDT)
In-Reply-To: <55FBCA11.7070604@kristov.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Sep 2015 10:23:45 +0200
Christoph Schulz <develop@kristov.de> wrote:

> Device names that match "help" or a prefix thereof should be allowed anywhere
> a device name can be used. Note that a suitable keyword ("dev" or "name", the
> latter for "ip tunnel") has to be used in these cases to resolve ambiguities.
> 
> Signed-off-by: Christoph Schulz <develop@kristov.de>
> Reported-by: Leonhard Preis <leonhard@pre.is>
> Reported-by: Wilhelm Wijkander <lists@0x5e.se>

This patch no longer applies cleanly after this patch that was just merged.



commit 940a96e6ca9a14cd52c97a719a1700b417adb2fb
Author: Phil Sutter <phil@nwl.cc>
Date:   Mon Sep 21 21:33:01 2015 +0200

    ip-link: do not support 'ip link add dev help'
    
    Commit 0532555 ('Support "ip link add help" for rtnl_link API') added a
    check for specified help parameter. Though due to the place where it has
    been added to, it is not possible anymore to force a given parameter to
    be interpreted as interface name by prefixing it with 'dev '. Fix this
    by forcing whatever follows 'dev' to be presumed as interface name.
    
    Signed-off-by: Phil Sutter <phil@nwl.cc>
