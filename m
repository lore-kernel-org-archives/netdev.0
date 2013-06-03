From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] include/linux/skbuff.h: using '0xffff' instead of '~0U'
Date: Mon, 03 Jun 2013 16:52:14 +0800
Message-ID: <51AC593E.4070503@asianux.com>
References: <51A6EBC5.7040601@asianux.com> <1369927806.2414.2.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, Pravin Shelar <pshelar@nicira.com>,
	mgorman@suse.de, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:64492 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884Ab3FCIxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 04:53:03 -0400
In-Reply-To: <1369927806.2414.2.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2013 11:30 PM, Ben Hutchings wrote:
> On Thu, 2013-05-30 at 14:03 +0800, Chen Gang wrote:
>> > Both 'transport_header' and 'mac_header' are u16, which are never equal
>> > to '~0U'.
>> > 
>> > So need use '0xffff' instead of '~0U'.
> ..and give this magic number a name?

It sounds a good idea. I will check which name is suitable for it, then
send patch v2, and please help to check it, too.


Thanks.
-- 
Chen Gang

Asianux Corporation
