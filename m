From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.26 0/3] RDMA/cxgb3: fixes and enhancements
	for 2.6.26
Date: Sun, 27 Apr 2008 10:54:56 -0500
Message-ID: <20080427155456.31018.22282.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, divy@chelsio.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
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

The following series fixes some bugs as well as enabling peer-2-peer
applications including OpenMPI and HPMPI.

I hope this can make 2.6.26.

NOTE: The changes in patch 3 require a new firmware version.  I added
the version change to drivers/net/cxgb3/version.h in this patch so that
the changes that require the new firmware as well as the version bump
are all in one git commit.  This keeps things like 'git bisect' from
leaving the driver broken.

--=20
Steve.
