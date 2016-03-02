From: Hau <hau@realtek.com>
Subject: RE: [PATCH net 0/3] r8169:issues fix.
Date: Wed, 2 Mar 2016 16:32:53 +0000
Message-ID: <80377ECBC5453840BA8C7155328B537701370DA1@RTITMBSV03.realtek.com.tw>
References: <1456476046-5436-1-git-send-email-hau@realtek.com>
 <20160301.152453.1743613743070525198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:57716 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbcCBQdF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 11:33:05 -0500
In-Reply-To: <20160301.152453.1743613743070525198.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't agree with changes #1 and #2.
> 
> If you are going to go to a model where every single configuration operation
> is recorded in software and performed at resume time, then really do it and
> fix it in the whole driver.  As currently coded you are leaving lots of known
> bugs in the driver.
> 
> #2 is even a worse situation.  If you are going to handle things this way you
> must sync the counters when the suspend happens, so that the statistics get
> call receives up to date values.

Thanks for your advice. I will send #3 patch first. Then modify #1 and #2 patch and resend these two patches.

 ------Please consider the environment before printing this e-mail.
