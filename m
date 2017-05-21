From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/9] dcb: enforce minimum length on IEEE_APPS
 attribute
Date: Sun, 21 May 2017 13:42:57 -0400 (EDT)
Message-ID: <20170521.134257.626474926003814542.davem@davemloft.net>
References: <20170519165556.483-1-sthemmin@microsoft.com>
        <20170519165556.483-2-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45174 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751233AbdEURnA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:43:00 -0400
In-Reply-To: <20170519165556.483-2-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 19 May 2017 09:55:48 -0700

> Found by reviewing the warning about unused policy table.
> The code implies that it meant to check for size, but since
> it unrolled the loop for attribute validation that is never used.
> Instead do explicit check for attribute.
> 
> Compile tested only. Needs review by original author.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
