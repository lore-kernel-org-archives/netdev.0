From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: Delete an unnecessary check before the function
 call "release_firmware"
Date: Thu, 05 Feb 2015 00:07:02 -0800 (PST)
Message-ID: <20150205.000702.1696491862930980641.davem@davemloft.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<54D1F6AF.2090408@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <54D1F6AF.2090408@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Wed, 04 Feb 2015 11:38:39 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Wed, 4 Feb 2015 11:28:43 +0100
> 
> The release_firmware() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Applied.
