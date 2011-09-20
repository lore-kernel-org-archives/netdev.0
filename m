From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: bridge carrier issue
Date: Tue, 20 Sep 2011 16:00:18 -0700 (PDT)
Message-ID: <c1e52584-2b98-4e95-bfb1-fe4cd64c1c47@tahiti.vyatta.com>
References: <20110920.152953.448244771460257273.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58626 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499Ab1ITXAT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 19:00:19 -0400
In-Reply-To: <20110920.152953.448244771460257273.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looked at dnsmasq and it needs some more work to handle IPv6 address
correctly. It sleeps if it gets a tentative address.

radvd probably has similar issues.
