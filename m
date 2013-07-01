From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch net-next 2/5] net: introduce generic inet_pton()
Date: Mon, 01 Jul 2013 15:02:53 +0800
Message-ID: <1372662173.2974.17.camel@cr0>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
	 <1372315398-19683-3-git-send-email-amwang@redhat.com>
	 <1372347124.2436.3.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Eric Dumazet <edumazet@google.com>,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372347124.2436.3.camel@bwh-desktop.uk.level5networks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-27 at 16:32 +0100, Ben Hutchings wrote:
> The return values for this are awful.  I think the return value should
> be 0 for success or -EINVAL on error.
> 
> The caller can then check addr->sa.sa_family if they want to know the
> address family immediately. 

Indeed, I will fix it.

Thanks!
