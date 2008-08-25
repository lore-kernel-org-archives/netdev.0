From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9] bnx2x: Multi Queue
Date: Mon, 25 Aug 2008 15:30:11 -0700 (PDT)
Message-ID: <20080825.153011.235553346.davem@davemloft.net>
References: <1219674304.19456.34.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gertner@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33327
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753207AbYHYWaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 18:30:14 -0400
In-Reply-To: <1219674304.19456.34.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 25 Aug 2008 17:25:04 +0300

> The multi queue support is still disabled by default for the bnx2x
> (needs some more testing and validation), but there are 2 obvious bug in
> it which are fixed in this patch
> 
> Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, but this is a completely inappropriate change to be sending
at this time.  If multiqueue is disabled, then users absolutely cannot
hit any real bug due to these incorrect pieces of code.  Therefore it
is not fixing something that we should be trying to deal with outside
of the merge window.

Can I make a suggestion?  Instead of bombing me with 10 patches at a time,
is it possible to send a patch every day or so instead, as you write them?

That makes things enormously easier for me, because when I have to instead
bunch up several at a time I have to push this to Linus and all he sees
is lots of changes outside of the merge window all at once and I have to
explain to him why all of these changes are "really needed".

I know this probably doesn't mesh well with how you guys do development
and testing, but I hope you can see how it puts me into a corner as we
get deeper and deeper into the RC series. :(
