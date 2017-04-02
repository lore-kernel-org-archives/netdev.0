From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 10/13] ftgmac100: Add a reset task and use it for link
 changes
Date: Mon, 03 Apr 2017 06:56:35 +1000
Message-ID: <1491166595.26047.11.camel@kernel.crashing.org>
References: <20170402033523.9482-1-benh@kernel.crashing.org>
         <20170402033523.9482-11-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:56120 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751738AbdDBU4n (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Apr 2017 16:56:43 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v32KudmT026396
        for <netdev@vger.kernel.org>; Sun, 2 Apr 2017 15:56:41 -0500
In-Reply-To: <20170402033523.9482-11-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-04-02 at 13:35 +1000, Benjamin Herrenschmidt wrote:
> +       /* Block PHY polling */
> +       if (netdev->phydev)
> +               mutex_lock(&netdev->phydev->lock);
> +
> +       rtnl_lock();

Self-given brown paper bag, those two need to be taken the other way
around. I'll send an updated patch today.

Cheers,
Ben.
