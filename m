From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v10 00/12] Add driver bpf hook for early packet drop
 and forwarding
Date: Tue, 19 Jul 2016 22:09:59 -0700 (PDT)
Message-ID: <20160719.220959.1735534229001351021.davem@davemloft.net>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	saeedm@dev.mellanox.co.il, kafai@fb.com, brouer@redhat.com,
	as754m@att.com, alexei.starovoitov@gmail.com, gerlitz.or@gmail.com,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	tgraf@suug.ch, tom@herbertland.com, daniel@iogearbox.net,
	ttoukan.linux@gmail.com
To: bblanco@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbcGTFKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 01:10:05 -0400
In-Reply-To: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brenden Blanco <bblanco@plumgrid.com>
Date: Tue, 19 Jul 2016 12:16:45 -0700

> This patch set introduces new infrastructure for programmatically
> processing packets in the earliest stages of rx, as part of an effort
> others are calling eXpress Data Path (XDP) [1]. Start this effort by
> introducing a new bpf program type for early packet filtering, before
> even an skb has been allocated.
> 
> Extend on this with the ability to modify packet data and send back out
> on the same port.

Series applied, thanks.
