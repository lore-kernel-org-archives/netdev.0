From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 net-next] ip route: Add RTM_F_LOOKUP_TABLE flag and
 show table id
Date: Wed, 23 Sep 2015 16:14:37 -0700
Message-ID: <20150923161437.7e055fc2@urahara>
References: <1442859588-14831-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35737 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755037AbbIWXO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 19:14:26 -0400
Received: by pacfv12 with SMTP id fv12so54136514pac.2
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 16:14:25 -0700 (PDT)
In-Reply-To: <1442859588-14831-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Sep 2015 11:19:48 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> Currently 'ip route get' does not show the table the lookup result comes
> from and prior to kernel commit c36ba6603a11 the response from the kernel
> was hardcoded to the main table. From the discussion this appears to be
> a leftover from the route cache where the cached entry lost the table id
> and so the result was hardcoded to main table.
> 
> c36ba6603a11 added the RTM_F_LOOKUP_TABLE flag to maintain that behavior
> but to allow new tools to ask for the actual table id for the lookup.
> This patch adds that flag to ip route get request and if the result is
> not the main table shows the table id.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, the compatibility concerns seem to be abated.
