From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: xfrm audit calls
Date: Wed, 12 Sep 2007 01:57:05 -0700 (PDT)
Message-ID: <20070912.015705.112612829.davem@davemloft.net>
References: <200709120003.l8C03E4G004949@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com
To: latten@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:48060
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761563AbXILI5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 04:57:11 -0400
In-Reply-To: <200709120003.l8C03E4G004949@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joy Latten <latten@austin.ibm.com>
Date: Tue, 11 Sep 2007 19:03:14 -0500

> This patch modifies the current ipsec audit layer
> by breaking it up into purpose driven audit calls.
> 
> So far, the only audit calls made are when add/delete
> an SA/policy. It had been discussed to give each 
> key manager it's own calls to do this, but I found
> there to be much redundnacy since they did the exact 
> same things, except for how they got auid and sid, so I 
> combined them. The below audit calls can be made by any 
> key manager. Hopefully, this is ok.
> 
> I compiled and tested with CONFIG_AUDITSYSCALLS on and off.
> 
> Signed-off-by: Joy Latten <latten@austin.ibm.com>

Patch applied, thanks!
