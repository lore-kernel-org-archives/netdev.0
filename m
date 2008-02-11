From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.25] cxgb3: Handle ARP completions that mark neighbors
 stale.
Date: Mon, 11 Feb 2008 11:09:25 -0500
Message-ID: <47B07335.5090709@garzik.org>
References: <20080206180519.4680.34741.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758579AbYBKQJo@vger.kernel.org>
In-Reply-To: <20080206180519.4680.34741.stgit@dell3.ogc.int>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
> cxgb3: Handle ARP completions that mark neighbors stale.
> 
> When ARP completes due to a request rather than a reply the neighbor is
> marked NUD_STALE instead of reachable (see arp_process()).  The handler
> for the resulting netevent needs to check also for NUD_STALE.
> 
> Failure to use the arp entry can cause RDMA connection failures.
> 
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>

applied
