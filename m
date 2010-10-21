From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Forward reserved group addresses if !STP
Date: Thu, 21 Oct 2010 04:29:37 -0700 (PDT)
Message-ID: <20101021.042937.58434576.davem@davemloft.net>
References: <20101018093837.26bb149a@nehalam>
	<1287454175-22903-1-git-send-email-benjamin.poirier@polymtl.ca>
	<20101018202858.7342f2cb@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benjamin.poirier@polymtl.ca, herbert@gondor.hengli.com.au,
	eric.dumazet@gmail.com, jpirko@redhat.com,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43482
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756254Ab0JUL3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:29:14 -0400
In-Reply-To: <20101018202858.7342f2cb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 18 Oct 2010 20:28:58 -0700

> On Mon, 18 Oct 2010 22:09:35 -0400
> Benjamin Poirier <benjamin.poirier@polymtl.ca> wrote:
> 
>> Make all frames sent to reserved group MAC addresses (01:80:c2:00:00:00 to
>> 01:80:c2:00:00:0f) be forwarded if STP is disabled. This enables
>> forwarding EAPOL frames, among other things.
>> 
>> Signed-off-by: Benjamin Poirier <benjamin.poirier@polymtl.ca>
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
