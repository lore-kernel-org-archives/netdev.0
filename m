From: David Miller <davem@davemloft.net>
Subject: Re: atl1c: Do not call cancel_work_sync from the work itself
Date: Mon, 03 Aug 2009 13:20:49 -0700 (PDT)
Message-ID: <20090803.132049.77191266.davem@davemloft.net>
References: <12492775393830-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43888
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752822AbZHCUUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 16:20:40 -0400
In-Reply-To: <12492775393830-git-send-email-jie.yang@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <jie.yang@atheros.com>
Date: Mon, 3 Aug 2009 13:32:19 +0800

> Signed-off-by: jie yang <jie.yang>@atheros.com

Your entire email address should be surrounded by '<' and '>'
characters, not just your username, in the signoff.

Also, please provide a more detailed commit message.  Explain what
goes wrong in the current code (when happens when a work is cancelled
within itself, I was under the impression that this works just fine
and is just a NOP), and the basic description of your solution.
