From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] qlge: bugfix: Fix ring length setting for rx ring,
 large/small
Date: Sun, 04 Jan 2009 17:09:46 -0800 (PST)
Message-ID: <20090104.170946.13427221.davem@davemloft.net>
References: <20081230211122.GD16018@susedev.qlogic.org>
	<1230671545-19084-4-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com,
	bhutchings@solarflare.com, hch@infradead.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40531
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751342AbZAEBJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 20:09:42 -0500
In-Reply-To: <1230671545-19084-4-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Tue, 30 Dec 2008 13:12:24 -0800

> The length field for these rings is 16-bits.  If the length is
> the max supported 65536 then the setting should be zero.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
