From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Re: [PATCH 6/6] IB: userspace support for
	RDMA connection manager
Date: Mon, 06 Mar 2006 14:28:14 -0800 (PST)
Message-ID: <20060306.142814.109285730.davem@davemloft.net>
References: <adaoe0j5kd6.fsf@cisco.com> <440CACB5.2010609@ichips.intel.com>
	<adabqwj5j7b.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: rdreier@cisco.com
In-Reply-To: <adabqwj5j7b.fsf@cisco.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 06 Mar 2006 13:58:32 -0800

>     Sean> Unless I miss counted, they should be aligned.
>     Sean> ib_user_path_rec is defined near the end of patch 1/6.
> 
> You're right.  struct sockaddr_in6 is 28 bytes long (not a multiple of
> 8) but gcc seems to lay everything out the same on 32-bit and 64-bit
> architectures just the same.

Please make sure you check "x86_64 vs. x86", and then something like
"powerpc64 vs. powerpc32" or "sparc64 vs. sparc32", as those are the
two different classes of ABI layouts.
