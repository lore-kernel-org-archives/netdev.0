From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: ipset losing entries on its own
Date: Wed, 06 Sep 2017 13:37:06 +0300
Message-ID: <c7abf292ac5e6202993a10a66537141e@nuclearcat.com>
References: <CAA5aLPhEseXhOqSK=6K=5J2q-zn+8FpxhqOBV5NqCPNMAJqhow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:33880 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753020AbdIFKhO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 06:37:14 -0400
In-Reply-To: <CAA5aLPhEseXhOqSK=6K=5J2q-zn+8FpxhqOBV5NqCPNMAJqhow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-09-06 13:08, Akshat Kakkar wrote:
> I am having ipset 6.32
> 
> The hash type is hash:ip
> 
> I am adding/deleting IP addresses to it dynamically using scripts.
> 
> However, it has been observed that at times few IPs (3-4 out of 4000)
> are not found in the set though it was added. Also, logs show there
> was not request for deletion of that IP from IPSet.
> 
> Is it a bug?

I think you should try to make script to create at least reproducible 
scenario
And sure post more info about your setup (kernel version, vanilla or 
distro)
