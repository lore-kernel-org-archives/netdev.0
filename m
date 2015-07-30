From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] act_bpf: fix memory leaks when replacing bpf
 programs
Date: Wed, 29 Jul 2015 23:57:06 -0700 (PDT)
Message-ID: <20150729.235706.1301630743612331900.davem@davemloft.net>
References: <414a0b7318a7d8a33f1a1d5ec051f47a17c41c11.1438187493.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, ast@plumgrid.com, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbbG3G5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 02:57:07 -0400
In-Reply-To: <414a0b7318a7d8a33f1a1d5ec051f47a17c41c11.1438187493.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 29 Jul 2015 18:40:56 +0200

> We currently trigger multiple memory leaks when replacing bpf
> actions, besides others:
 ...
> Fixes: d23b8ad8ab23 ("tc: add BPF based action")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable, thanks Daniel.
