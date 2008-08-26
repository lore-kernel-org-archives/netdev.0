From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 8/9] bnx2x: Multi Queue
Date: Tue, 26 Aug 2008 10:34:07 +0300
Message-ID: <1219736047.18453.4.camel@lb-tlvb-eliezer>
References: <1219674304.19456.34.camel@lb-tlvb-eliezer>
 <20080825.153011.235553346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Yitchak Gertner" <yitchak.gertner@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2802 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752100AbYHZHfe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 03:35:34 -0400
In-Reply-To: <20080825.153011.235553346.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-08-25 at 15:30 -0700, David Miller wrote:
> From: "Eilon Greenstein" <eilong@broadcom.com>
> Date: Mon, 25 Aug 2008 17:25:04 +0300

> Applied, but this is a completely inappropriate change to be sending
> at this time.  If multiqueue is disabled, then users absolutely cannot
> hit any real bug due to these incorrect pieces of code.  Therefore it
> is not fixing something that we should be trying to deal with outside
> of the merge window.
Point taken. The reason we applied this patch was due to users enabling
this feature and reporting errors - but on retrospect I shouldn't have
sent it to this tree

> 
> Can I make a suggestion?  Instead of bombing me with 10 patches at a time,
> is it possible to send a patch every day or so instead, as you write them?
> 
> That makes things enormously easier for me, because when I have to instead
> bunch up several at a time I have to push this to Linus and all he sees
> is lots of changes outside of the merge window all at once and I have to
> explain to him why all of these changes are "really needed".
> 
> I know this probably doesn't mesh well with how you guys do development
> and testing, but I hope you can see how it puts me into a corner as we
> get deeper and deeper into the RC series. :(
I hear you - if (when...) we will root cause the next
serious-enough-to-be-submitted bug I will send it (and only it) ASAP

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


