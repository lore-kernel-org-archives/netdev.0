From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/14] batman-adv: drop dependency against CRC16
Date: Wed, 15 Jan 2014 16:54:41 -0800 (PST)
Message-ID: <20140115.165441.1381803061248668589.davem@davemloft.net>
References: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
	<1389652298-472-15-git-send-email-antonio@meshcoding.com>
	<52D68A1C.3080302@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbaAPAym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 19:54:42 -0500
In-Reply-To: <52D68A1C.3080302@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Wed, 15 Jan 2014 14:16:12 +0100

> On 13/01/14 23:31, Antonio Quartulli wrote:
>> The crc16 functionality is not used anymore, therefore
>> we can safely remove the dependency in the Kbuild file.
>> 
>> Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
> 
> David,
> 
> we just realized that this dependency is still needed by our module.
> (also thanks to Fengguang Wu build bot!)
> 
> Could you please revert this patch only?

I've reverted this change from net-next, thanks.
