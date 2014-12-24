From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip: allow ip address show to list addresses
 with certain flags not being set
Date: Wed, 24 Dec 2014 12:16:49 -0800
Message-ID: <20141224121649.3ef9d61d@urahara>
References: <54986E93.4030108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Heiner Kallweit <hkallweit1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:34670 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbaLXUQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 15:16:59 -0500
Received: by mail-pd0-f174.google.com with SMTP id fp1so10419241pdb.33
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 12:16:59 -0800 (PST)
In-Reply-To: <54986E93.4030108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Dec 2014 20:18:43 +0100
Heiner Kallweit <hkallweit1@gmail.com> wrote:

> Sometimes it's needed to have "ip address show" list only addresses
> with certain flags not being set, e.g. in network scripts.
> As an example one might want to exclude addresses in "tentative"
> or "deprecated" state.
> 
> Support listing addresses with flags tentative, deprecated, dadfailed
> not being set by prefixing the respective flag with a minus.
> 
> Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>

Applied, but please send another patch to update manual page.
