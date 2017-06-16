From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 1/3] networking: make skb_put & friends return void
 pointers
Date: Fri, 16 Jun 2017 13:03:40 +0200
Message-ID: <1497611020.2622.8.camel@sipsolutions.net>
References: <20170615221217.16510-1-johannes@sipsolutions.net>
         <20170615221217.16510-2-johannes@sipsolutions.net>
         <871sqke5co.fsf@miraculix.mork.no>
         <1497602577.2622.5.camel@sipsolutions.net>
         <1497609558.10546.5.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>,
        =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:59954 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752375AbdFPLDo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 07:03:44 -0400
In-Reply-To: <1497609558.10546.5.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-16 at 03:39 -0700, Joe Perches wrote:
> 
> I would suggest avoiding using skb_put_u8 as it
> would suggest there should be skb_put_u16 etc

If there are enough users, I don't know why we wouldn't add it? Though
it should be _unaligned_le16 and _unaligned_be16, if at all :)

johannes
