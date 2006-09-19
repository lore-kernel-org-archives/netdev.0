From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3][ATM]: potential NULL pointer dereference in
 clip_mkip()
Date: Tue, 19 Sep 2006 12:59:39 -0700 (PDT)
Message-ID: <20060919.125939.25157436.davem@davemloft.net>
References: <200609170019.k8H0JLER025309@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31890
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752039AbWIST7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 15:59:34 -0400
To: chas@cmf.nrl.navy.mil
In-Reply-To: <200609170019.k8H0JLER025309@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Date: Sat, 16 Sep 2006 20:19:21 -0400

> please consider for 2.6.18 -- thanks!
> 
> [ATM]: potential NULL pointer dereference in clip_mkip()
> 
> http://article.gmane.org/gmane.linux.kernel/445717
> 
> When re-processing received data, a struct sk_buff pointer skb may be
> dereferenced after a free operation.
> 
> From: Frederik Deweerdt <deweerdt@free.fr>
> Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

Hideaki YOSHIFUJI posted a better version of the fix which is
already in Linus's tree.

Thanks.
