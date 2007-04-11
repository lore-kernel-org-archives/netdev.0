From: David Miller <davem@davemloft.net>
Subject: Re: [SK_BUFF]: Fix missing offset adjustment in skb_copy_expand
Date: Tue, 10 Apr 2007 18:31:03 -0700 (PDT)
Message-ID: <20070410.183103.45875481.davem@davemloft.net>
References: <461849C5.8000507@trash.net>
	<461C2F13.1080808@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46223
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965865AbXDKBbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 21:31:03 -0400
In-Reply-To: <461C2F13.1080808@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 11 Apr 2007 02:42:59 +0200

> Hi Dave,
> 
> Patrick McHardy wrote:
> > [SK_BUFF]: Fix missing offset adjustment in skb_copy_expand
> > 
> > skb_copy_expand changes the headroom, so it needs to adjust the header
> > offsets by the difference between the old and the new value.
> 
> 
> it seems like you missed this one. Attached again for your convenience.

Thanks a lot Patrick, applied.

I know what happened, I applied the pskb_copy_expand() patch and then
deleted this one by accident since the subject lines looked so
similar and I figured I was just getting a second copy of the same
patch :-)

Thanks again!
