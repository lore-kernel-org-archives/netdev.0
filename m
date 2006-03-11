From: "Sean Hefty" <sean.hefty@intel.com>
Subject: RE: [PATCH 4/6 v2] IB: address translation to map IP toIB addresses (GIDs)
Date: Fri, 10 Mar 2006 22:10:38 -0800
Message-ID: <ORSMSX401FRaqbC8wSA00000019__33101.9177953296$1142057490$gmane$org@orsmsx401.amr.corp.intel.com>
References: <ada1wx9hjfe.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<openib-general@openib.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751222AbWCKGKp@vger.kernel.org>
To: "'Roland Dreier'" <rdreier@cisco.com>
In-Reply-To: <ada1wx9hjfe.fsf@cisco.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>The ib_addr module depends on CONFIG_INET, because it uses symbols
>like arp_tbl, which are only exported if INET is enabled.
>
>I fixed this up by creating a new (non-user-visible) config symbol to
>control when ib_addr is built -- I put the following diff on top of
>your patch in my tree:

Thanks!
-Sean
