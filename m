From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: rds: Don't allocate rds_sock on stack
Date: Mon, 25 Aug 2014 13:33:33 +0200
Message-ID: <2003093.xT3MtFJFAa@wuerfel>
References: <1408926755-12277-1-git-send-email-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Mark Brown <broonie@kernel.org>, Chien Yen <chien.yen@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, Mark Brown <broonie@linaro.org>
To: linaro-kernel@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:51068 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932163AbaHYLdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 07:33:45 -0400
In-Reply-To: <1408926755-12277-1-git-send-email-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 24 August 2014 19:32:35 Mark Brown wrote:
> From: Mark Brown <broonie@linaro.org>
> 
> struct rds_sock is rather large ausing the following warning in an ARM
> allmodconfig:
> 
> net/rds/iw_rdma.c:200:1: warning: the frame size of 1056 bytes is larger than 1024 bytes [-Wframe-larger-than=]
> 
> Fix this by dynamically allocating struct rds_sock in rds_iw_update_cm_id
> instead of allocating it on the stack.
> 
> Signed-off-by: Mark Brown <broonie@linaro.org>
> 

Acked-by: Arnd Bergmann <arnd@arndb.de>
