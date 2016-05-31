From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] sctp: sctp_diag should dump sctp socket type
Date: Tue, 31 May 2016 11:59:34 -0700 (PDT)
Message-ID: <20160531.115934.448180712677695713.davem@davemloft.net>
References: <56c3ecedbc132e8501fd7cfbe056525155a1f915.1464514933.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net, phil@nwl.cc
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36705 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbcEaS7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 14:59:36 -0400
In-Reply-To: <56c3ecedbc132e8501fd7cfbe056525155a1f915.1464514933.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sun, 29 May 2016 17:42:13 +0800

> Now we cannot distinguish that one sk is a udp or sctp style when
> we use ss to dump sctp_info. it's necessary to dump it as well.
> 
> For sctp_diag, ss support is not officially available, thus there
> are no official users of this yet, so we can add this field in the
> middle of sctp_info without breaking user API.
> 
> v1->v2:
>   - move 'sctpi_s_type' field to the end of struct sctp_info, so
>     that it won't cause incompatibility with applications already
>     built.
>   - add __reserved3 in sctp_info to make sure sctp_info is 8-byte
>     alignment.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
