From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Check the value of doi before referencing it
Date: Wed, 18 May 2011 01:04:53 -0400 (EDT)
Message-ID: <20110518.010453.1295824792800350412.davem@davemloft.net>
References: <1305692980-4730-1-git-send-email-huzaifas@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, pekkas@netcore.fi, kuznet@ms2.inr.ac.ru
To: huzaifas@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab1ERFIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 01:08:55 -0400
In-Reply-To: <1305692980-4730-1-git-send-email-huzaifas@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huzaifa Sidhpurwala <huzaifas@redhat.com>
Date: Wed, 18 May 2011 09:59:40 +0530

> Value of doi is not checked before referencing it.
> Though this does not cause any null pointer dereference since
> all the callers of cipso_v4_doi_add check the value of doi
> before calling the function, but it would be a good programming
> practice to do so anyways :)
> 
> Signed-off-by: Huzaifa Sidhpurwala <huzaifas@redhat.com>

I don't think we should fix bugs that do not exist.
