From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: always add flag an address that failed DAD with
 DADFAILED
Date: Sun, 10 Jan 2016 22:54:40 -0500 (EST)
Message-ID: <20160110.225440.375655096836234129.davem@davemloft.net>
References: <1452257243-19389-1-git-send-email-lkundrak@v3.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: lkundrak@v3.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452257243-19389-1-git-send-email-lkundrak@v3.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lubomir Rintel <lkundrak@v3.sk>
Date: Fri,  8 Jan 2016 13:47:23 +0100

> The userspace needs to know why is the address being removed so that it can
> perhaps obtain a new address.
> 
> Without the DADFAILED flag it's impossible to distinguish removal of a
> temporary and tentative address due to DAD failure from other reasons (device
> removed, manual address removal).
> 
> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>

Applied.
