From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v3 4/7] vxlan: improve vxlan route lookup
 checks.
Date: Thu, 17 Nov 2016 10:17:01 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0222355@AcuExch.aculab.com>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
        <1479098638-4921-5-git-send-email-pshelar@ovn.org>
 <20161115153934.363e176d@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Jiri Benc' <jbenc@redhat.com>, Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.188]:65172 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751640AbcKQKRH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 05:17:07 -0500
In-Reply-To: <20161115153934.363e176d@griffin>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Of Jiri Benc
> Sent: 15 November 2016 14:40
> On Sun, 13 Nov 2016 20:43:55 -0800, Pravin B Shelar wrote:
> > @@ -1929,8 +1951,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
> >  	union vxlan_addr *src;
> >  	struct vxlan_metadata _md;
> >  	struct vxlan_metadata *md = &_md;
> > -	struct dst_entry *ndst = NULL;
> >  	__be16 src_port = 0, dst_port;
> > +	struct dst_entry *ndst = NULL;
> >  	__be32 vni, label;
> >  	__be16 df = 0;
> >  	__u8 tos, ttl;
> 
> This looks kind of arbitrary. You might want to remove this hunk or
> merge it to patch 3.

Worse than arbitrary, it adds 4 bytes of pad on 64bit systems.

	David
