From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] TCP: Bug fix in initialization of receive window.
Date: Wed, 08 Dec 2010 09:41:23 -0800 (PST)
Message-ID: <20101208.094123.28798820.davem@davemloft.net>
References: <1291419224-20853-1-git-send-email-nanditad@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chavey@google.com, ycheng@google.com, netdev@vger.kernel.org
To: nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57793
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755257Ab0LHRk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 12:40:56 -0500
In-Reply-To: <1291419224-20853-1-git-send-email-nanditad@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nandita Dukkipati <nanditad@google.com>
Date: Fri,  3 Dec 2010 15:33:44 -0800

> The bug has to do with boundary checks on the initial receive window.
> If the initial receive window falls between init_cwnd and the
> receive window specified by the user, the initial window is incorrectly
> brought down to init_cwnd. The correct behavior is to allow it to
> remain unchanged.
> 
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>

Applied and queued up for -stable, thanks.
