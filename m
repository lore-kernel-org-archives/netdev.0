From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: mac address fix
Date: Fri, 13 Nov 2009 19:52:30 -0800 (PST)
Message-ID: <20091113.195230.02147359.davem@davemloft.net>
References: <1258114975-5715-1-git-send-email-stas@lvk.cs.msu.su>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aabdulla@nvidia.com, yinghai@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: stas@lvk.cs.msu.su
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757692AbZKNDwQ@vger.kernel.org>
In-Reply-To: <1258114975-5715-1-git-send-email-stas@lvk.cs.msu.su>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Stanislav O\. Bezzubtsev" <stas@lvk.cs.msu.su>
Date: Fri, 13 Nov 2009 15:22:55 +0300

> Set second bit of randomly generated mac. That marks MAC
> as locally assigned. IEEE802.3, section one, 3.2.3.
> 
> Signed-off-by: Stanislav O. Bezzubtsev <stas@lvk.cs.msu.su>

Do you know why this driver even has this bug?

It's because it does not use random_ether_addr() and tries to
do it by hand all by itself.

Please fix this bug for real by having the driver use the proper
interface to calculate a randomized ethernet address.

Thank you.
