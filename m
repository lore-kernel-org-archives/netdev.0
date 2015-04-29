From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH net-next v3 1/4] net core: Add IFF_PROTO_DOWN
 support.
Date: Wed, 29 Apr 2015 15:13:36 -0700
Message-ID: <20150429151336.0d6d8aab@urahara>
References: <1430156304-13187-2-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sfeldma@gmail.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	wkok@cumulusnetworks.com
To: anuradhak@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34338 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbbD2WNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 18:13:36 -0400
Received: by pacyx8 with SMTP id yx8so40017339pac.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:13:36 -0700 (PDT)
In-Reply-To: <1430156304-13187-2-git-send-email-anuradhak@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Apr 2015 10:38:21 -0700
anuradhak@cumulusnetworks.com wrote:

> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> 
> This patch introduces an IFF_PROTO_DOWN flag that can be used by
> user space applications to notify drivers that errors have been
> detected on the device.
> 
> Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>

I worry that adding another bit to an already complex state API
will break userspace.

There are lots of things besides iproute2 which look at those
flags including routing daemons (quagga), network manager, netplugd,
and switch controllers.
