From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] rttable: Fix invalid range checking when table
 id is converted to u32
Date: Thu, 12 Jan 2017 17:36:21 -0800
Message-ID: <20170112173621.1d124bb4@xeon-e3>
References: <1484091235-17749-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, frank.kellermann@atos.net
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33188 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdAMBgX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 20:36:23 -0500
Received: by mail-pf0-f177.google.com with SMTP id y143so22020735pfb.0
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 17:36:23 -0800 (PST)
In-Reply-To: <1484091235-17749-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jan 2017 15:33:55 -0800
David Ahern <dsa@cumulusnetworks.com> wrote:

> Frank reported that table ids for very large numbers are not properly
> detected:
> $ ip li add foobar type vrf table 98765432100123456789
> 
> command succeeds and resulting table id is actually:
> 
> 21: foobar: <NOARP,MASTER> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>     link/ether da:ea:d4:77:38:2a brd ff:ff:ff:ff:ff:ff promiscuity 0
>     vrf table 4294967295 addrgenmode eui64 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
> 
> Make the temp variable 'i' unsigned long and let the typecast to u32
> happen on assignment to id.
> 
> Reported-by: Frank Kellermann <frank.kellermann@atos.net>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied thanks.
