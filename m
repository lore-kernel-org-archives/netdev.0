From: "Ben Menchaca (ben@bigfootnetworks.com)" <ben@bigfootnetworks.com>
Subject: RE: [RFC PATCH] gianfar: fix undo of reserve()
Date: Wed, 24 Mar 2010 13:13:22 -0700
Message-ID: <A6A1774AFD79E346AE6D49A33CB294530DC1A006@EX-BE-017-SFO.shared.themessagecenter.com>
References: <A6A1774AFD79E346AE6D49A33CB294530DC19FC4@EX-BE-017-SFO.shared.themessagecenter.com>
 <20100324.114759.200629461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.themessagecenter.com ([208.113.96.229]:2680 "EHLO
	out02.themessagecenter.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756545Ab0CXUNh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 16:13:37 -0400
In-Reply-To: <20100324.114759.200629461.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So, is this tested at least a little bit?
We run a 2.6.31 variant on our board, and this patch fixes the skb->len issue, and we are not observing any strangeness under the stress conditions after this patch, and our asserts are no longer firing.  2.6.31 was pre-multiq for gianfar, though, and that was a large change...I would definitely prefer getting some modern-ish kernel time on it.  If needed, I can probably move our board forward to -next for a bit.

For some history, and to see the original issue addressed, this appears to have been introduced shortly after recycling in 2.6.30, here:
commit d4a76f8a619b5d7dfd5a0f122666fee24bb3dcb9
gianfar: fix BUG under load after introduction of skb recycling

- Ben

