From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/2] net: 3com: typhoon: typhoon_init_one: fix
 incorrect return values
Date: Fri, 30 Dec 2016 15:27:09 -0500 (EST)
Message-ID: <20161230.152709.841426532104836350.davem@davemloft.net>
References: <1482873453.20986.4.camel@dillow-glaptop.roam.corp.google.com>
        <1483065474-11512-1-git-send-email-thomas.preisner+linux@fau.de>
        <1483065474-11512-2-git-send-email-thomas.preisner+linux@fau.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-kernel@i4.cs.fau.de,
        milan.stephan+linux@fau.de, sergei.shtylyov@cogentembedded.com
To: thomas.preisner+linux@fau.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483065474-11512-2-git-send-email-thomas.preisner+linux@fau.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Preisner <thomas.preisner+linux@fau.de>
Date: Fri, 30 Dec 2016 03:37:53 +0100

> In a few cases the err-variable is not set to a negative error code if a
> function call in typhoon_init_one() fails and thus 0 is returned
> instead.
> It may be better to set err to the appropriate negative error
> code before returning.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188841
> 
> Reported-by: Pan Bian <bianpan2016@163.com>
> Signed-off-by: Thomas Preisner <thomas.preisner+linux@fau.de>
> Signed-off-by: Milan Stephan <milan.stephan+linux@fau.de>

Applied to net-next.
