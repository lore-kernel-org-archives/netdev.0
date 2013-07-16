From: Joe Perches <joe@perches.com>
Subject: Re: sysfs_format_mac
Date: Tue, 16 Jul 2013 13:46:26 -0700
Message-ID: <1374007586.1949.25.camel@joe-AO722>
References: <20130716.125641.1190207010366517153.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:57493 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933670Ab3GPUq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jul 2013 16:46:27 -0400
In-Reply-To: <20130716.125641.1190207010366517153.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-16 at 12:56 -0700, David Miller wrote:
> 
> I assume that the only reason sysfs_format_mac() exists at all, and
> don't just use scnprintf() calls with "%pm\n", is that some devices
> have MAC addresses which are not 6 bytes in length.
> 
> But it's such a waste to have this special case piece of code
> just for that.
> 
> It would make so much more sense to allow specifying a length
> specifier to %pm and friends.

scnprintf("%*ph", (int)size, buffer)
