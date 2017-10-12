From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][bpf-next] bpf: remove redundant variable old_flags
Date: Wed, 11 Oct 2017 20:23:00 -0700 (PDT)
Message-ID: <20171011.202300.1480286300516136187.davem@davemloft.net>
References: <20171011105623.19998-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42164 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751347AbdJLDXB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 23:23:01 -0400
In-Reply-To: <20171011105623.19998-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Wed, 11 Oct 2017 11:56:23 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Variable old_flags is being assigned but is never read; it is redundant
> and can be removed.
> 
> Cleans up clang warning: Value stored to 'old_flags' is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
