From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/5] phylib: don't return NULL from get_phy_device()
Date: Mon, 25 Apr 2016 12:45:49 -0700
Message-ID: <571E73ED.7080603@gmail.com>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
 <16806435.OmqP10ba8M@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35526 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933450AbcDYTsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 15:48:06 -0400
Received: by mail-pf0-f173.google.com with SMTP id n1so72720976pfn.2
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 12:48:05 -0700 (PDT)
In-Reply-To: <16806435.OmqP10ba8M@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/04/16 10:25, Sergei Shtylyov wrote:
> Arnd Bergmann asked that get_phy_device() returns either NULL or the error
> value,  not both on error.  Do as he said, return ERR_PTR(-ENODEV) instead
> of NULL when the PHY ID registers read as  all ones.
> 
> Suggested-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
