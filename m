From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 0/3] bridge: filtering by vlan id
Date: Mon, 11 Apr 2016 17:30:05 +0200
Message-ID: <570BC2FD.8010201@cumulusnetworks.com>
References: <1460380710-29583-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36530 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702AbcDKPaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 11:30:08 -0400
Received: by mail-wm0-f54.google.com with SMTP id v188so91397013wme.1
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 08:30:07 -0700 (PDT)
In-Reply-To: <1460380710-29583-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2016 03:18 PM, Nikolay Aleksandrov wrote:
> Hi,
> This set adds support for filtering by a vlan id when showing fdb/mdb/vlan
> entries. Currently the filtering is implemented entirely in user-space, but
> the plan is to add kernel support as well. The vlan show part is also needed
> for the future per-vlan statistics in order to be able to show them only for
> a specific vlan. I plan to update the bridge man page soon as it's missing
> other options too and it seemed inconsistent to add this given that there're
> potential paragraphs missing, thus I'll post a separate patch for that.
> 
> Thank you,
>  Nik
> 

Self-NAK, after discussing with colleagues, we think it'd be better not to print
the non-matching ports at all (right now they're printed with empty "vlan ids"
column). I'll post a v2 with updated patch 03.

Cheers,
 Nik
