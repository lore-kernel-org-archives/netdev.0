From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] sch_red: fix weighted average calculation
Date: Fri, 14 Sep 2012 15:13:16 +0200
Message-ID: <1347628396.26523.6.camel@edumazet-glaptop>
References: <1347543820-27548-1-git-send-email-cyril@ti.com>
	 <1347544431.13103.1557.camel@edumazet-glaptop>
	 <2D29FFBF554947468515B8EF6C733BB72E564F65@DLEE09.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Chemparathy, Cyril" <cyril@ti.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"david.ward@ll.mit.edu" <david.ward@ll.mit.edu>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>
To: "Dowdal, John" <jdowdal@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2D29FFBF554947468515B8EF6C733BB72E564F65@DLEE09.ent.ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-09-14 at 13:01 +0000, Dowdal, John wrote:
> Eric, thank you for reviewing the code.  I now see the problem with
> the patch since backlog is an integer and qavg is a fixed point number
> at logW.  
> 
> We are considering another patch to update the comments to this code
> (with the actual C code change reverted) to stop the FPP by showing
> the derivation of the equation in the comments.  Does this sound good?

This would be good, please do so.

Thanks
