From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH net-next iproute2 PATCH 2/2 v2] ss: Add inet raw sockets
 information gathering via netlink diag interface
Date: Thu, 1 Dec 2016 22:13:06 +0300
Message-ID: <20161201191306.GC26799@uranus>
References: <1478092496-7540-1-git-send-email-gorcunov@gmail.com>
 <1478092496-7540-3-git-send-email-gorcunov@gmail.com>
 <20161201105701.1c54b258@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, avagin@openvz.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33220 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751451AbcLATN3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 14:13:29 -0500
Received: by mail-lf0-f68.google.com with SMTP id 98so19895970lfs.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 11:13:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161201105701.1c54b258@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2016 at 10:57:01AM -0800, Stephen Hemminger wrote:
> 
> Applied both patches, but needed to remove inet_diag.h since
> already updated kernel headers.

Thank you! I think we might need to extend the matching interface
for killing raw sockets in near future, because for now it is
too wildcard. I put this into my todo list, once I finish with
more urgent tasks will back to this one.
