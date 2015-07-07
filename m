From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: add support for linkdown sysctl to netconf
Date: Tue, 7 Jul 2015 10:21:53 -0400
Message-ID: <20150707142152.GB588@gospo.home.greyhouse.net>
References: <1436206919-973-1-git-send-email-gospo@cumulusnetworks.com>
 <559B8685.4020509@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:33532 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757054AbbGGOVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 10:21:53 -0400
Received: by qkhu186 with SMTP id u186so140788481qkh.0
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 07:21:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <559B8685.4020509@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 07, 2015 at 09:57:57AM +0200, Nicolas Dichtel wrote:
> Le 06/07/2015 20:21, Andy Gospodarek a =E9crit :
> >This kernel patch exports the value of the new
> >ignore_routes_with_linkdown via netconf.
> >
> >Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> >Suggested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> >---
> You need also to patch devinet_conf_proc() so that a netlink message =
is
> sent when the user updates the sysctl entry.

Doh!  I had that change in a different topic branch, but didn't
cherry-pick correctly before posting.  Thanks for catching this!
