From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute PATCH v4 3/5] Replace malloc && memset by calloc
Date: Fri, 15 Jul 2016 09:33:33 -0600
Message-ID: <563a9fbd-0057-132a-85c2-06ee4079a100@cumulusnetworks.com>
References: <1468435639-6892-1-git-send-email-phil@nwl.cc>
 <1468435639-6892-4-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34568 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbcGOPdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 11:33:36 -0400
Received: by mail-io0-f169.google.com with SMTP id q83so107670326iod.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 08:33:35 -0700 (PDT)
In-Reply-To: <1468435639-6892-4-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/13/16 12:47 PM, Phil Sutter wrote:
> This only replaces occurrences where the newly allocated memory is
> cleared completely afterwards, as in other cases it is a theoretical
> performance hit although code would be cleaner this way.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
> Changes since v2:
> - Fix checkpatch errors.
> ---
>  genl/genl.c        |  3 +--
>  lib/names.c        |  7 ++-----
>  misc/lnstat.c      |  6 ++----
>  misc/lnstat_util.c |  4 +---
>  tc/em_canid.c      |  4 ++--
>  tc/m_action.c      |  3 +--
>  tc/m_ipt.c         | 13 ++++---------
>  tc/m_pedit.c       |  3 +--
>  tc/tc.c            |  9 +++------
>  tc/tc_bpf.c        |  4 +---
>  tc/tc_class.c      |  3 +--
>  tc/tc_exec.c       |  3 +--
>  12 files changed, 20 insertions(+), 42 deletions(-)


Acked-by: David Ahern <dsa@cumulusnetworks.com>
