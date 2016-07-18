From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute PATCH v5 4/5] No need to initialize rtattr fields before
 parsing
Date: Mon, 18 Jul 2016 10:10:30 -0600
Message-ID: <fc5e64e2-d016-35a0-3630-ccc4838acd5c@cumulusnetworks.com>
References: <1468853325-9260-1-git-send-email-phil@nwl.cc>
 <1468853325-9260-5-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:33587 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773AbcGRQKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 12:10:52 -0400
Received: by mail-io0-f181.google.com with SMTP id 38so163933666iol.0
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 09:10:33 -0700 (PDT)
In-Reply-To: <1468853325-9260-5-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/18/16 8:48 AM, Phil Sutter wrote:
> Since parse_rtattr_flags() calls memset already, there is no need for
> callers to do so themselves.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/ipaddress.c | 2 +-
>  tc/tc_class.c  | 4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)

Acked-by: David Ahern <dsa@cumulusnetworks.com>
