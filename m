From: David Miller <davem@davemloft.net>
Subject: Re: [patch] econet: unlock on -EPERM path
Date: Wed, 08 Dec 2010 10:14:24 -0800 (PST)
Message-ID: <20101208.101424.189706549.davem@davemloft.net>
References: <20101207110138.GM10623@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, philb@gnu.org, eric.dumazet@gmail.com,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58539
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752464Ab0LHSN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:13:56 -0500
In-Reply-To: <20101207110138.GM10623@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Tue, 7 Dec 2010 14:01:38 +0300

> We need to do a mutex_unlock() and a put_dev() before returning.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Nelson Elhage beat you to this one, so I integrates his version.

Thanks.
