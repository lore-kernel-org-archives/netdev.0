From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] carl9170: Convert byte_rev_table uses to bitrev8
Date: Thu, 13 Nov 2014 21:32:44 -0800
Message-ID: <1415943164.5912.4.camel@perches.com>
References: <35FD53F367049845BC99AC72306C23D103E010D1829D@CNBJMBX05.corpusers.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "'chunkeey@googlemail.com'" <chunkeey@googlemail.com>,
	"'linville@tuxdriver.com'" <linville@tuxdriver.com>,
	"'linux-wireless@vger.kernel.org'" <linux-wireless@vger.kernel.org>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0217.hostedemail.com ([216.40.44.217]:53733 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751258AbaKNFcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 00:32:47 -0500
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E010D1829D@CNBJMBX05.corpusers.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-11-14 at 13:16 +0800, Wang, Yalin wrote:
> Use the inline function instead of directly indexing the array.
> 
> This allows some architectures with hardware instructions for bit
> reversals to eliminate the array.

This one is already in -next

commit 7a1283d8f5298437a454ec477384dcd9f9f88bac
Author: Joe Perches <joe@perches.com>
Date:   Tue Oct 28 14:18:58 2014 -0700

    carl9170: Convert byte_rev_table uses to bitrev8
    
    Use the inline function instead of directly indexing the array.
    
    This allows some architectures with hardware instructions
    for bit reversals to eliminate the array.
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>
