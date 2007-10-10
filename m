From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] do not give access to 1-1024 ports for autobinding
Date: Wed, 10 Oct 2007 15:52:38 -0700 (PDT)
Message-ID: <20071010.155238.130616908.davem@davemloft.net>
References: <20071010143449.GA10796@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56812
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756272AbXJJWwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:52:36 -0400
In-Reply-To: <20071010143449.GA10796@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 10 Oct 2007 18:34:49 +0400

> This patch prevents possibility to give 1-1024 port range for autobinding.
> {1, 1} may only takes some sense for deep embedded people.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Administrators can configure their systems however they want,
the numbers are valid port numbers, so we should not prevent
the possibility.
