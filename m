From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Correct accept(2) recovery after sock_attach_fd()
Date: Mon, 26 Mar 2007 14:20:20 -0700 (PDT)
Message-ID: <20070326.142020.36925087.davem@davemloft.net>
References: <20070326153431.GA6805@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: adobriyan@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58233
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753164AbXCZVUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 17:20:21 -0400
In-Reply-To: <20070326153431.GA6805@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@sw.ru>
Date: Mon, 26 Mar 2007 19:34:31 +0400

> * d_alloc() in sock_attach_fd() fails leaving ->f_dentry of new file NULL
> * bail out to out_fd label, doing fput()/__fput() on new file
> * but __fput() assumes valid ->f_dentry and dereferences it
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>

Thanks for this bug fix Alexey, patch applied.
