From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Re: [PATCH 6/6] IB: userspace support for RDMA
	connection manager
Date: Mon, 06 Mar 2006 13:58:32 -0800
Message-ID: <adabqwj5j7b.fsf@cisco.com>
References: <ORSMSX4011XvpFVjCRG00000009@orsmsx401.amr.corp.intel.com>
	<adaoe0j5kd6.fsf@cisco.com> <440CACB5.2010609@ichips.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Sean Hefty <mshefty@ichips.intel.com>
In-Reply-To: <440CACB5.2010609@ichips.intel.com> (Sean Hefty's message of "Mon,
	06 Mar 2006 13:42:13 -0800")
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

    Sean> Unless I miss counted, they should be aligned.
    Sean> ib_user_path_rec is defined near the end of patch 1/6.

You're right.  struct sockaddr_in6 is 28 bytes long (not a multiple of
8) but gcc seems to lay everything out the same on 32-bit and 64-bit
architectures just the same.

 - R.
