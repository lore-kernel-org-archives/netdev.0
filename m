From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute PATCH v5 2/5] Use C99 style initializers everywhere
Date: Mon, 18 Jul 2016 10:09:50 -0600
Message-ID: <30954b1d-9245-1d08-3117-f47e782a7486@cumulusnetworks.com>
References: <1468853325-9260-1-git-send-email-phil@nwl.cc>
 <1468853325-9260-3-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:33149 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbcGRQKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 12:10:07 -0400
Received: by mail-io0-f176.google.com with SMTP id 38so163912983iol.0
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 09:09:52 -0700 (PDT)
In-Reply-To: <1468853325-9260-3-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/18/16 8:48 AM, Phil Sutter wrote:
> This big patch was compiled by vimgrepping for memset calls and changing
> to C99 initializer if applicable. One notable exception is the
> initialization of union bpf_attr in tc/tc_bpf.c: changing it would break
> for older gcc versions (at least <=3.4.6).
>
> Calls to memset for struct rtattr pointer fields for parse_rtattr*()
> were just dropped since they are not needed.
>
> The changes here allowed the compiler to discover some unused variables,
> so get rid of them, too.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---

Acked-by: David Ahern <dsa@cumulusnetworks.com>
