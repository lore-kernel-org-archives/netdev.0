From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: Re: [PATCH net-next] ieee802154: fix new function declaration
Date: Wed, 26 Feb 2014 12:43:50 +0100
Message-ID: <20140226124350.0c858ece@zoidberg>
References: <1393393109-11079-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:45256 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbaBZLoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 06:44:06 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s1QBi41x032183
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 12:44:04 +0100
In-Reply-To: <1393393109-11079-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Feb 2014 22:38:29 -0700
Jean Sacren <sakiwit@gmail.com> wrote:

> The commit 8fad346f366a7 ("eee802154: add basic support for RF212 to
> at86rf230 driver") introduced the new function is_rf212() with some
> minor issues in declaration:
> 
> 1) Fix the function type by changing it to bool as the function
>    definition returns a boolean value. Additionally both callers of
>    is_rf212() are expected to return a boolean value.
> 
> 2) Fix the function specifier by deleting the inline keyword as the
>    compiler takes care of that.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> Cc: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>

+1. My original intent was to have is_rf212 as a predicate like that,
but I slipped.
