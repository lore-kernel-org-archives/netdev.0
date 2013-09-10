From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH net-next] net: sk_buff: memset(skb,0) after alloc in
 skb_clone
Date: Tue, 10 Sep 2013 08:33:38 +0200
Message-ID: <20130910063338.GE20862@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Reply-To: <1378788533-5609-1-git-send-email-govindarajulu90@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <govindarajalu90@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:52791 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753630Ab3IJGdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 02:33:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dont think this is necessary. Use GFP_ZERO mask in the skb_clone() call instead.

//E
