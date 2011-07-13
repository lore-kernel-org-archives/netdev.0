From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] slip: remove redundant check slip_devs for NULL
Date: Wed, 13 Jul 2011 02:32:32 -0700 (PDT)
Message-ID: <20110713.023232.62732068177679052.davem@davemloft.net>
References: <CAKh5naa_ARaJvZFOMva9V22YCTkVyPMw1+-x=GTtx-niwpOFSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965169Ab1GMJce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 05:32:34 -0400
In-Reply-To: <CAKh5naa_ARaJvZFOMva9V22YCTkVyPMw1+-x=GTtx-niwpOFSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matvejchikov Ilya <matvejchikov@gmail.com>
Date: Wed, 13 Jul 2011 11:46:57 +0400

> As slip_devs is initialized on module load stage there is no reason to
> check it for NULL anywhere instead of the deinitialization routine because
> if we can't get enough memory on startup we don't run at all.
> 
> Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>

Applied.
