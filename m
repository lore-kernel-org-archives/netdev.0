From: Davide Caratti <dcaratti@redhat.com>
Subject: Re: Documentation error for checksum offload check ?
Date: Fri, 07 Apr 2017 09:35:57 +0200
Message-ID: <1491550557.2505.12.camel@redhat.com>
References: <1491524586.4166.144.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55132 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753311AbdDGHf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 03:35:59 -0400
In-Reply-To: <1491524586.4166.144.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-07 at 10:23 +1000, Benjamin Herrenschmidt wrote:
> I noticed in both Documentation/networking/checksum-offload.txt
> and include/linux/skbuff.h reference to helpers
> 
> skb_csum_off_chk*
> c
> Now, I can't find anything like that with grep ... :-)
> 
> Am I missing something ?
> 
> Cheers,
> Ben.
> 

hello Benjamin,

these functions are not present anymore in the kernel since commit
cf53b1da73bd ('Revert "net: Add driver helper functions to determine
checksum"'). You might find some additional information on this thread
in linux-sctp (https://www.spinics.net/lists/linux-sctp/msg05606.html),
there is an ongoing proposal for fixing Documentation/networking/checksum-offload.txt,
improve referenced paragraphs in include/linux/sk_buff.h, and maybe
extend the current API.

regards,
