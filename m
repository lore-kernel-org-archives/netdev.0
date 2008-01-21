From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH RESEND 0/3] RDMA/cxgb3 fixes
Date: Mon, 21 Jan 2008 14:41:30 -0600
Message-ID: <20080121204130.3820.11053.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
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

Hey Roland,

Please include these three iw_cxgb3 fixes for 2.6.25.  The first two fix
bugs found doing Lustre testing, and the last patch correctly marks
privileged qps.

Shortlog:
      RDMA/cxgb3: Flush the RQ when closing.
      RDMA/cxgb3: fix page shift calculation in build_phys_page_list()
      RDMA/cxgb3: Mark qp as privileged based on user capabilities.

--=20
Steve.
