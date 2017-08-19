From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH 5/5] net: defxx: constify eisa_device_id
Date: Sat, 19 Aug 2017 13:06:56 +0100 (BST)
Message-ID: <alpine.LFD.2.20.1708191306120.19107@eddie.linux-mips.org>
References: <1503125614-15297-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:57548 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S23992517AbdHSMG4EN4zB (ORCPT
        <rfc822;netdev@vger.kernel.org> + 1 other);
        Sat, 19 Aug 2017 14:06:56 +0200
In-Reply-To: <1503125614-15297-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 19 Aug 2017, Arvind Yadav wrote:

> eisa_device_id are not supposed to change at runtime. All functions
> working with eisa_device_id provided by <linux/eisa.h> work with
> const eisa_device_id. So mark the non-const structs as const.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
> ---

Reviewed-by: Maciej W. Rozycki <macro@linux-mips.org>

  Maciej
