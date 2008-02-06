From: Divy Le Ray <divy@chelsio.com>
Subject: [ofa-general] Re: [PATCH 2.6.25] cxgb3: Handle ARP completions that
 mark neighbors stale.
Date: Wed, 06 Feb 2008 10:27:34 -0800
Message-ID: <47A9FC16.3070803@chelsio.com>
References: <20080206180519.4680.34741.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org,
	linux-kernel@vger.kernel.org, jeff@garzik.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080206180519.4680.34741.stgit@dell3.ogc.int>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
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
>   

Acked-by: Divy Le Ray <divy@chelsio.com>

Divy
