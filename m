From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] pasemi_mac: mac_to_intf() error not noticed
Date: Thu, 23 Apr 2009 12:56:48 -0500
Message-ID: <20090423175648.GA4406@lixom.net>
References: <49F0A8E9.2010702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:42075 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751236AbZDWRzW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 13:55:22 -0400
Content-Disposition: inline
In-Reply-To: <49F0A8E9.2010702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2009 at 07:44:09PM +0200, Roel Kluin wrote:
> mac_to_intf() can return -1 when no device or function was found, but when
> mac->dma_if is unsigned. The error wasn't noticed.

This can in practice never happen which is likely why it went
unnoticed.

I object to the usage of err in the way you use it, it's completely
counterintuitive to name a variable that will hold valid data to 'err'.

So, define a new variable with an appropriate name, please.


-Olof

