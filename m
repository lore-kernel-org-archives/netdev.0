From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RESEND] [PATCH v2] [3/5] pasemi_mac: cleanups and rx performance
 improvements
Date: Sat, 28 Apr 2007 11:22:43 -0400
Message-ID: <463366C3.7020701@pobox.com>
References: <20070428054952.GA22074@lixom.net> <20070428055112.GD22074@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52059 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031206AbXD1PWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 11:22:45 -0400
In-Reply-To: <20070428055112.GD22074@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> NAPI fixes and cleanups for pasemi_mac:
> 
> * Timer changes/fixes
> * Abstract out the rx intr restart to a separate function
> * Similar function for tx intr to reset to a known clear state even if
>   firmware used the same interface
> * Add a copy-break and recycle the SKB in the driver for small
>   packets
> * Other minor changes to rx path

Split out the "abstract out function foo" style changes into a separate 
patch.

This creates a smaller and much more reviewable second patch as a 
result.  Doing so also creates a nice, clean git-bisect point that can 
be used to guarantee the validity of the first patch.

	Jeff



