From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] vrf: Add support for table names
Date: Thu, 10 Dec 2015 08:55:55 -0800
Message-ID: <20151210085555.4aece36c@xeon-e3>
References: <1449606284-42134-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36055 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418AbbLJQzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 11:55:47 -0500
Received: by pacdm15 with SMTP id dm15so50330367pac.3
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 08:55:47 -0800 (PST)
In-Reply-To: <1449606284-42134-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  8 Dec 2015 12:24:44 -0800
David Ahern <dsa@cumulusnetworks.com> wrote:

> Currently, the table id for VRF devices requires an integer. Convert
> it to use rtnl_rttable_a2n which handles table names from the iproute2
> directory.
> 
> This also fixes a bug in the original commit where table name are not
> properly handled.
> 
> Fixes: 15faa0a30bed ("add support for VRF device")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks.
