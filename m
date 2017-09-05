From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/10] ixgbe: Use ARRAY_SIZE macro
Date: Tue, 05 Sep 2017 11:50:44 -0700 (PDT)
Message-ID: <20170905.115044.551456011251065741.davem@davemloft.net>
References: <1504439110050-939061377-0-diffsplit-thomas@m3y3r.de>
        <1504439110050-1907815276-6-diffsplit-thomas@m3y3r.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thomas@m3y3r.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36888 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752113AbdIESup (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 14:50:45 -0400
In-Reply-To: <1504439110050-1907815276-6-diffsplit-thomas@m3y3r.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Meyer <thomas@m3y3r.de>
Date: Sun, 03 Sep 2017 14:19:31 +0200

> Use ARRAY_SIZE macro, rather than explicitly coding some variant of it
> yourself.
> Found with: find -type f -name "*.c" -o -name "*.h" | xargs perl -p -i -e
> 's/\bsizeof\s*\(\s*(\w+)\s*\)\s*\ /\s*sizeof\s*\(\s*\1\s*\[\s*0\s*\]\s*\)
> /ARRAY_SIZE(\1)/g' and manual check/verification.
> 
> Signed-off-by: Thomas Meyer <thomas@m3y3r.de>

This should be submitted to the Intel ethernet driver maintainers.

Thank you.
