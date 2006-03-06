From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 6/6] IB: userspace support for RDMA
	connection manager
Date: Mon, 06 Mar 2006 13:35:27 -0800
Message-ID: <adak6b75k9s.fsf@cisco.com>
References: <ORSMSX4011XvpFVjCRG00000009@orsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "Sean Hefty" <sean.hefty@intel.com>
In-Reply-To: <ORSMSX4011XvpFVjCRG00000009@orsmsx401.amr.corp.intel.com> (Sean
	Hefty's message of "Mon, 6 Mar 2006 11:21:04 -0800")
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

I think it makes sense to merge patches 1-5 independently of this
patch.  The kernel interface is needed by iSER and NFS/RDMA, and
maintaining compatibility isn't a huge deal, so we can merge it now
(assuming it looks mergable).

On the other hand I think it would be good to let this userspace
interface cook a little more, say in -mm.

Anyone have any problems with that plan?

 - R.
