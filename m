From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: disallow bpf tc programs access
 current->pid,uid
Date: Mon, 15 Jun 2015 20:51:40 -0700 (PDT)
Message-ID: <20150615.205140.723220112308012803.davem@davemloft.net>
References: <1434426564-6176-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43809 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbbFPDxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 23:53:35 -0400
In-Reply-To: <1434426564-6176-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 15 Jun 2015 20:49:24 -0700

> Accessing current->pid/uid from cls_bpf may lead to misleading results and
> should not be used when TC classifiers need accurate information about pid/uid.
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks.
