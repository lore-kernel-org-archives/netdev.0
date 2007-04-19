From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: AF_PACKET how to get the original netdev from a packet received
 from a bonded master
Date: Thu, 19 Apr 2007 14:55:33 -0600
Message-ID: <4627D745.2000004@nortel.com>
References: <41b516cb0704181652o6a05b570t511ee23373a0b3ac@mail.gmail.com> <20070418.170749.07021824.davem@davemloft.net> <41b516cb0704181717l2c6c15a0j9ae275d15c6b22f4@mail.gmail.com> <20070418.180622.35354420.davem@davemloft.net> <41b516cb0704181902q646c4f9bvc34e79393ee974a3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chavey@google.com,
	netdev@vger.kernel.org
To: Chris Leech <chris.leech@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:51795 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1766981AbXDSUz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 16:55:57 -0400
In-Reply-To: <41b516cb0704181902q646c4f9bvc34e79393ee974a3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech wrote:

> Just to give you an idea of our motivation around this, we're looking
> at layer 2 configuration protocols implemented from user space.

I'd like to second the intent of this patch.  We've been maintaining a 
patch against 2.6.10 for a while now that exports the original ingress 
device to userspace via ancilliary data.  We use it in combination with 
bonding.

Was never submitted to mainline because we're on an old kernel.

Chris
