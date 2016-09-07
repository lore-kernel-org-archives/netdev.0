From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: ptp
Date: Wed, 7 Sep 2016 22:48:18 +0200
Message-ID: <20160907204818.GA7470@localhost.localdomain>
References: <d1b2b740-8cc6-bf4a-722b-7b323fb0c7c0@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>,
        "Shabeena Shabeena -X (sshabeen - ARICENT TECHNOLOGIES MAURIITIUS
        LIMITED at Cisco)" <sshabeen@cisco.com>
To: Daniel Walker <danielwa@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38765 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757188AbcIGUsY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 16:48:24 -0400
Received: by mail-wm0-f46.google.com with SMTP id 1so53857345wmz.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 13:48:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <d1b2b740-8cc6-bf4a-722b-7b323fb0c7c0@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 07, 2016 at 01:40:59PM -0700, Daniel Walker wrote:
> There is a test (below) , which prevents negative nanosecond updates. The
> code below would force a negative update to always return more than
> NSEC_PER_SEC. It should be using abs() instead which would return the value
> desired.

No.  This:

	/*
	 * The value of a timeval is the sum of its fields, but the
	 * field tv_usec must always be non-negative.
	 */

HTH,
Richard
