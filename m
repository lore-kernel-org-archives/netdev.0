From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHSET net-next v3 00/07] Support for byte queue limits on
 various drivers
Date: Sun, 20 Oct 2013 12:38:04 -0700
Message-ID: <1382297884.2041.48.camel@joe-AO722>
References: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Tino Reichardt <milky-kernel@mcmilk.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0083.hostedemail.com ([216.40.44.83]:37493 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751360Ab3JTTiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 15:38:08 -0400
In-Reply-To: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-10-20 at 21:23 +0200, Tino Reichardt wrote:
> Hello again,

Hi again Tino.

> "if (likely(bql_disable == false))" was replaced by
> "if (unlikely(bql_disable))" ...

Sorry for suggesting this, but it's not an
equivalent transform unless the then & else
paths are also inverted.

Here there are no else branches.
Doesn't this need to be?

from:
	if (likely(bql_disable == false))
to:
	if (likely(!bql_disable))
