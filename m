From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH 0/4][CRYPTO][IPsec] support XCBC
Date: Wed, 18 Oct 2006 11:25:55 +0900
Message-ID: <20061018112555.6ad5f1f0.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 221x116x13x66.ap221.ftth.ucom.ne.jp ([221.116.13.66]:58859 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S1751160AbWJRC0A
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 22:26:00 -0400
To: davem@davemloft.net, herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I send patches to support XCBC mode of IPsec.
This patch is for linux-2.6.19-rc2. I checked to also apply
this to net-2.6.

The patches does not use CBC mode in blkcipher. I think
blkcipher provides encryption function of blocks. XCBC
however needs only the last block of encryption. If I use
the CBC mode, I have to allocate output buffer which is same
length of input and is unnecessary.

I directly use the algorithm (internal transform) accordingly.

Best regards,

--
Kazunori Miyazawa
