From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2/9][TG3]: Improve ASF heartbeat.
Date: Wed, 27 Sep 2006 16:08:47 -0700
Message-ID: <1159398527.3411.34.camel@rh4>
References: <1159389265.3411.19.camel@rh4>
 <20060927.160123.78711404.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:38405 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1031228AbWI0XMP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 19:12:15 -0400
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060927.160123.78711404.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-09-27 at 16:01 -0700, David Miller wrote:

> But what exactly is meant by "checking the ring condition"?
> 
> Does it mean that if the ASF heartbeat times out, ASF will
> check to see if the TX and/or RX ring are still making forward
> progress and abort the reset if so?
> 

Exactly.  If the rx ring is not empty, it will check to see if the
consumer index of the rx ring is making forward progress.

