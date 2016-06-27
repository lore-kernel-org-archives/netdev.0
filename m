From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 3/3] ss: Add support to filter on device
Date: Mon, 27 Jun 2016 11:09:21 -0700
Message-ID: <20160627110921.7ae95e63@xeon-e3>
References: <1466566706-1511-1-git-send-email-dsa@cumulusnetworks.com>
	<1466566706-1511-4-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35815 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbcF0SJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 14:09:06 -0400
Received: by mail-pf0-f170.google.com with SMTP id c2so64163087pfa.2
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 11:09:06 -0700 (PDT)
In-Reply-To: <1466566706-1511-4-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2016 20:38:26 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> Add support for device names in the filter. Example:
> 
>     root@kenny:~# ss -t  'sport == :22 && dev == red'
>     State      Recv-Q Send-Q     Local Address:Port      Peer Address:Port
>     ESTAB      0      0          10.100.1.2%red:ssh      10.100.1.254:47814
>     ESTAB      0      0           2100:1::2%red:ssh        2100:1::64:49406
> 
> Since kernel does not support iface in the filter specifying a
> device name means all filtering is done in userspace.
> 

Introduces new checkpatch whitespace issues.
ERROR: code indent should use tabs where possible
#60: FILE: misc/ss.c:1337:
+               case SSF_DEVCOND:$

WARNING: please, no spaces at the start of a line
#60: FILE: misc/ss.c:1337:
+               case SSF_DEVCOND:$

ERROR: code indent should use tabs where possible
#63: FILE: misc/ss.c:1340:
+                return 0;$

WARNING: please, no spaces at the start of a line
#63: FILE: misc/ss.c:1340:
+                return 0;$
