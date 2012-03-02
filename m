From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: data is truncated in skb
Date: Fri, 2 Mar 2012 15:43:57 +0100
Message-ID: <20120302144357.GC31240@electric-eye.fr.zoreil.com>
References: <CAAZheX=A9=iuSDS+w4u_kqn4QvffdboKngopJgTegrsOUHQrHg@mail.gmail.com> <CAAZheXmgb=Se6YJdp=LpH0G1vco1oms2XARtXs3HTf3DKZtrRA@mail.gmail.com> <20120301200726.6b0d845c@nehalam.linuxnetplumber.net> <CAAZheX=R-MVoa1Cgs8+=zON6ZC7Van8tH-GermuCTK1PEK-9ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Syed Muhammad Mohsin Kazmi <08beesmmkazmi@seecs.edu.pk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49708 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753218Ab2CBOoV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 09:44:21 -0500
Content-Disposition: inline
In-Reply-To: <CAAZheX=R-MVoa1Cgs8+=zON6ZC7Van8tH-GermuCTK1PEK-9ew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Syed Muhammad Mohsin Kazmi <08beesmmkazmi@seecs.edu.pk> :
[...]
> 	if(skb->data == push3)
> 	{
> 		skb_set_mac_header(skb,0);
> 	
> 		skb_pull(skb,ETH_HLEN);

May be this skb_pull as a start. Hard to tell without context (and I am not
a free as in beer consultant for proprietary or academic homework).

[...]
> 	printk("\t\t\tencapsulated Buffer\n");

Help yourself: see Documentation/trace/kprobetrace.txt and check the
skb_xyz calls.

-- 
Ueomor
