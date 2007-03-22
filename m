From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Thu, 22 Mar 2007 12:01:39 -0700 (PDT)
Message-ID: <20070322.120139.74735307.davem@davemloft.net>
References: <200703221835.l2MIZdDw007850@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org, vyekkirala@trustedcs.com
To: latten@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36404
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965047AbXCVTBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 15:01:40 -0400
In-Reply-To: <200703221835.l2MIZdDw007850@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joy Latten <latten@austin.ibm.com>
Date: Thu, 22 Mar 2007 12:35:39 -0600

> Within selinux we check for authorization before deleting entries from
> SAD and SPD. 
> 
> We are not checking for authorization when flushing the SPD and
> the SAD. It was perhaps missed in original patch.
> 
> This patch adds security check when flushing entries from SAD and SPD.
> 
> Please let me know if this patch is ok.
> It was built against linux-2.6.21-rc4-git5. I have also tested it.
> 
> Signed-off-by: Joy Latten<latten@austin.ibm.com>

I don't understand this and it does not sit well with me.

If we are flushing the policy database, we are flushing it
regardless of what the security layer might or might not say.

I would look at this patch differently if there were some
security level key being checked for a match here, which is
an input key to the flush, but that is not what is happening
here as the object is being looked at by itself.
