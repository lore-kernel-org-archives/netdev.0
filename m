From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Do not keep linklocal and loopback addresses
Date: Wed, 13 Apr 2016 23:00:02 -0400 (EDT)
Message-ID: <20160413.230002.1718430497071707670.davem@davemloft.net>
References: <1460142081-16675-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655AbcDNDAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 23:00:04 -0400
In-Reply-To: <1460142081-16675-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri,  8 Apr 2016 12:01:21 -0700

> f1705ec197e7 added the option to retain user configured addresses on an
> admin down. A comment to one of the later revisions suggested using the
> IFA_F_PERMANENT flag rather than adding a user_managed boolean to the
> ifaddr struct. A side effect of this change is that link local and
> loopback addresses are also retained which is not part of the objective
> of f1705ec197e7. Add check to drop those addresses.
> 
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, but two things:

Please do not put an empty line between the Fixes: and other tags.
All tags are equal and should be placed together as an unsegmented
unit.

Second, please be really sure this is the final set of semantics
you want.  If we flap again on this after 4.6-final goes out the
door, I will be very unpleased to say the least.

Thanks.
