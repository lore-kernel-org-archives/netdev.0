From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/36] bnx2x patch series
Date: Wed, 12 Aug 2009 14:50:19 -0700 (PDT)
Message-ID: <20090812.145019.231249971.davem@davemloft.net>
References: <1250101162.27379.151.camel@lb-tlvb-eilong>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yanivr@broadcom.com, vladz@broadcom.com,
	gertner@broadcom.com, benli@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49513
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751685AbZHLVuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 17:50:09 -0400
In-Reply-To: <1250101162.27379.151.camel@lb-tlvb-eilong>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Come on... 36 patches? :-/

Please trickle changes in, don't send patch bombs.  I think
I've told you this not once, but several times.  But I keep
seeing these sizable patch sets.

I frankly don't care that it might not mesh well with how you code up
and validate changes internally, because it absolutely does NOT work
well for how bugs really get found and fixed upstream.

If you trickle changes in, the guilty change is obvious to spot and it
gets found before you do more development that depends upon that buggy
change.

Whereas if you patch bomb, someone has to do a lot of work and
bisecting to nail down the bad change.  And the bug might be so
fundamental in a patch that it also invalidates all the followon
work you did.

I really don't want to apply any of this stuff, to be honest with you.
I simply don't.  I keep giving guidelines and they keep getting
ignored.

