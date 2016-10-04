From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ptp: Fix resource leak in case of error
Date: Mon, 03 Oct 2016 21:54:37 -0400 (EDT)
Message-ID: <20161003.215437.766104609153539683.davem@davemloft.net>
References: <1475391856-15046-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475391856-15046-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Sun,  2 Oct 2016 09:04:16 +0200

> A call to 'ida_simple_remove()' is missing in the error handling path.
> 
> This as been spotted with the following coccinelle script which tries to
> detect missing 'ida_simple_remove()' call in error handling paths.
 ...
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Applied.
