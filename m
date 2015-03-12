From: Martin Walch <walch.martin@web.de>
Subject: Re: [PATCH] net:Kconfig: drop no sense dependence entry for BONDING
Date: Thu, 12 Mar 2015 16:14:15 +0100
Message-ID: <5969250.CkvXFhddBO@tacticalops>
References: <20150312135933.GA3502@udknight>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-kbuild@vger.kernel.org,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	Erik Hugne <erik.hugne@ericsson.com>
To: Wang YanQing <udknight@gmail.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20150312135933.GA3502@udknight>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 12 March 2015 21:59:33 Wang YanQing wrote:
> "IPV6 || IPV6=n" means no dependence!

IPV6 and BONDING are both tristate symbols and therefore this is not the same
as no dependency. When setting IPV6 to m, the expression evaluates to

"IPV6 || IPV6=n" 
"m || m=n"
"m || n"
"m"

So, if IPV6=m, then BONDING can only be n or m, but not y.

