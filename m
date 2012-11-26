From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix memory leak in sctp_datamsg_from_user() when
 copy from user space fails
Date: Mon, 26 Nov 2012 17:34:29 -0500 (EST)
Message-ID: <20121126.173429.323283427379416132.davem@davemloft.net>
References: <1353590491-12166-1-git-send-email-tt.rantala@gmail.com>
	<50B38235.6070908@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tt.rantala@gmail.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, nhorman@tuxdriver.com, sri@us.ibm.com,
	davej@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756271Ab2KZWee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 17:34:34 -0500
In-Reply-To: <50B38235.6070908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Mon, 26 Nov 2012 09:52:37 -0500

> Should be using sctp_chunk_free().  Good find.

Tommi, please respin your patch to use sctp_chunk_free() as
Vlad has asked.

Thanks.
