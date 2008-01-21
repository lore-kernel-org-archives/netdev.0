From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3][NET] gen_estimator: list_empty() check in
 est_timer() fixed
Date: Mon, 21 Jan 2008 02:36:32 -0800 (PST)
Message-ID: <20080121.023632.122420355.davem@davemloft.net>
References: <20080120155544.0a071675@deepthought>
	<20080121063455.GA981@ff.dom.local>
	<20080121064240.GB981@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, slavon@bigtelecom.ru,
	kaber@trash.net, hadi@cyberus.ca, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40255
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758585AbYAUKg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 05:36:27 -0500
In-Reply-To: <20080121064240.GB981@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 21 Jan 2008 07:42:40 +0100

> On Mon, Jan 21, 2008 at 07:34:55AM +0100, Jarek Poplawski wrote:
> ...
> > BTW, I've forgotten to mention with patch 1/3 that this checking with
> > warning on gen_new_estimator() double call should be only temporary,
> > and after more testing gen_estimator structure could be probably
> > decreased after removing bstats and rate_est fields.
> 
> Hmm, let's forget about this again: it's too early in the morning...

:-)

FWIW I agree that double-negatives are confusing and we should
avoid them.
