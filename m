From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 NEXT 0/5]qlcnic: aer state
Date: Wed, 14 Jul 2010 10:31:47 -0700 (PDT)
Message-ID: <20100714.103147.193705183.davem@davemloft.net>
References: <1279089215-23231-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59860
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751565Ab0GNRbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 13:31:32 -0400
In-Reply-To: <1279089215-23231-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: amit.salecha@qlogic.com
Date: Tue, 13 Jul 2010 23:33:30 -0700

>   I was in under impression that using space after tab is illegal.

What's undesirable is using spaces instead of tabs for fresh
code-block lines like:

	foo();

Also, it is undesirable to have spaces mixed into the middle of a
sequence of tab characters.  The spaces, when used to align expression
continuation lines or lists of function arguments, should be at the
end.

So in cases like:

	if (foo &&
	    bar)

The second line should be a tab character, then the spaces to make
the alignment happen.
