From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC,v3 02/10] dpaa_eth: add support for DPAA Ethernet
Date: Wed, 10 Jun 2015 07:44:12 -0700
Message-ID: <1433947452.27504.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430319405-31280-1-git-send-email-madalin.bucur@freescale.com>
	 <DM2PR0301MB086380B3D89425345562F384F3BD0@DM2PR0301MB0863.namprd03.prod.outlook.com>
	 <BL2PR03MB545CA85B1FE886FCD07DE26E6BD0@BL2PR03MB545.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jianhua Xie <Jianhua.Xie@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
To: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:33695 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754082AbbFJOoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 10:44:16 -0400
In-Reply-To: <BL2PR03MB545CA85B1FE886FCD07DE26E6BD0@BL2PR03MB545.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-10 at 07:38 +0000, Madalin-Cristian Bucur wrote:
> Hi Eric,
> 
> Can you please tell us if this change would be for the better?
> 
> I was about to say yes to this request but checked and no other Ethernet driver seems to use the queue trans_start.
> I was able to find your patch "net: tx scalability works : trans_start" [ http://patchwork.ozlabs.org/patch/27104/ ] but did not find more about this topic.
>  

Drivers no longer have to worry about updating trans_start themselves.
Core networking stack handles this.

Check txq_trans_update() done from netdev_start_xmit()
