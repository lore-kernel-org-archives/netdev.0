From: Anton Ivanov <anton.ivanov@cambridgegreys.com>
Subject: Not BUG, feature :) af_packet fails to TX TSO frames
Date: Fri, 13 Oct 2017 08:25:29 +0100
Message-ID: <1b445a1b-12bc-5e36-50ba-3a683b7096e2@cambridgegreys.com>
References: <c3002d4f-62ff-1d0b-65fb-b366be45a6d8@cambridgegreys.com>
 <CAF=yD-+SxQTHxiU5Yi2f8dm6X1s7SA6PdkbeJP-K_9ZuTMAaTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab5.miniserver.com ([78.31.111.25]:36739 "EHLO
        www.kot-begemot.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751901AbdJMHZb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 03:25:31 -0400
In-Reply-To: <CAF=yD-+SxQTHxiU5Yi2f8dm6X1s7SA6PdkbeJP-K_9ZuTMAaTA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let's reset this one.

I cannot say I am happy with the current number of caveats on using 
this. We should at least throw a small page similar to the one dedicated 
to tpacket_v2 into the kernel docs (or amend the offload docs). As I do 
not know all the corner cases well enough I find it difficult to 
volunteer on this one, it should be someone more familiar with the code. 
If they are documented, we can say that this is not a bug, it is a 
feature :)

What I can volunteer on is contributing some code to the actual 
af_packet.c. When I did the digging in the source, I noticed that tap 
has an unfair advantage over raw by allowing the user to specify buffers 
from userspace. I am happy to port that, test it and contribute it.

-- 
Anton R. Ivanov

Cambridge Greys Limited, England and Wales company No 10273661
http://www.cambridgegreys.com/
