From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] devlink: Call dl_free in early exit case
Date: Sat, 18 Feb 2017 16:30:34 -0800
Message-ID: <20170218163034.3f193429@xeon-e3>
References: <20170214052938.16727-1-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:35844 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750838AbdBSAah (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 19:30:37 -0500
Received: by mail-pg0-f49.google.com with SMTP id v184so25464417pgv.3
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 16:30:37 -0800 (PST)
In-Reply-To: <20170214052938.16727-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Feb 2017 07:29:38 +0200
Leon Romanovsky <leon@kernel.org> wrote:

> From: Leon Romanovsky <leonro@mellanox.com>
> 
> Prior to parsing command options, the devlink tool allocates memory
> to store results. In case of early exit (wrong parameters or version
> check), this memory wasn't freed.
> 
> Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks.
