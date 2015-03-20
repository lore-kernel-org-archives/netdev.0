From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v2] xen-netback: making the bandwidth limiter runtime
 settable
Date: Fri, 20 Mar 2015 10:11:55 +0000
Message-ID: <20150320101155.GO16267@zion.uk.xensource.com>
References: <1426759542-15948-1-git-send-email-imrep.amz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, "Palik, Imre" <imrep@amazon.de>,
	"Anthony Liguori" <aliguori@amazon.com>
To: Imre Palik <imrep.amz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426759542-15948-1-git-send-email-imrep.amz@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 19, 2015 at 11:05:42AM +0100, Imre Palik wrote:
> From: "Palik, Imre" <imrep@amazon.de>
> 
> With the current netback, the bandwidth limiter's parameters are only
> settable during vif setup time.  This patch register a watch on them, and
> thus makes them runtime changeable.
> 
> When the watch fires, the timer is reset.  The timer's mutex is used for
> fencing the change.
> 
> Cc: Anthony Liguori <aliguori@amazon.com>
> Signed-off-by: Imre Palik <imrep@amazon.de>

Acked-by: Wei Liu <wei.liu2@citrix.com>
