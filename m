From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: compat_sys_recvmmsg user timespec arg can be
 NULL
Date: Wed, 02 Dec 2009 01:23:42 -0800 (PST)
Message-ID: <20091202.012342.82734338.davem@davemloft.net>
References: <1259689936-27570-1-git-send-email-acme@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jean-mickael.guerin@6wind.com,
	acme@redhat.com
To: acme@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55300
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751366AbZLBJXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 04:23:36 -0500
In-Reply-To: <1259689936-27570-1-git-send-email-acme@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@infradead.org>
Date: Tue,  1 Dec 2009 15:52:16 -0200

> From: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
> 
> We must test if user timespec is non-NULL before copying from userpace,
> same as sys_recvmmsg().
> 
> Commiter note: changed it so that we have just one branch.
> 
> Signed-off-by: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied.
