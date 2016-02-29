From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xt_osf: remove unused variable
Date: Mon, 29 Feb 2016 14:00:20 +0100
Message-ID: <20160229130020.GA16348@salvia>
References: <1456215010-14878-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456215010-14878-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 23, 2016 at 01:40:10PM +0530, Sudip Mukherjee wrote:
> While building with W=1 we got the warning:
> net/netfilter/xt_osf.c:265:9: warning: variable 'loop_cont' set but not used
> 
> The local variable loop_cont was only initialized and then assigned a
> value but was never used or checked after that.
> While removing the variable, the case of OSFOPT_TS was not removed so
> that it will serve as a reminder to us that we can do something in that
> particular case.

Applied, thanks.
