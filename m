From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: Return error instead of partial read for
 saved syn headers
Date: Tue, 19 May 2015 16:33:50 -0400 (EDT)
Message-ID: <20150519.163350.407818271127074601.davem@davemloft.net>
References: <1431974158-28288-1-git-send-email-emunson@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: emunson@akamai.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431974158-28288-1-git-send-email-emunson@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric B Munson <emunson@akamai.com>
Date: Mon, 18 May 2015 14:35:58 -0400

> Currently the getsockopt() requesting the cached contents of the syn
> packet headers will fail silently if the caller uses a buffer that is
> too small to contain the requested data.  Rather than fail silently and
> discard the headers, getsockopt() should return an error and report the
> required size to hold the data.
> 
> Signed-off-by: Eric B Munson <emunson@akamai.com>

Applied, thanks Eric.
