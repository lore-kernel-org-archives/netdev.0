From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.22 0/5] iw_cxgb3: Bug Fixes + Firmware
	update
Date: Thu, 26 Apr 2007 15:20:57 -0500
Message-ID: <20070426202057.24234.56383.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org, divy@chelsio.com,
	linux-kernel@vger.kernel.org
To: rdreier@cisco.com,jeff@garzik.org
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

Here are some bug fixes to the iw_cxgb3 driver that I'd like merged for
2.6.22.  The 1st patch has been posted before, but I didn't see it in
your for-2.6.22 branch, so I'm posting it again. =20

Jeff,=20

The last patch updates the cxgb3 required firmware version.  It is
included in this series because its required by the patch preceeding it
in the series.

Steve.

Shortlog:

Steve Wise:
      Fix TERM codes.
      Fail qp creation if the requested max_inline is too large.
      Initialize cpu_idx field in cpl_close_listserv_req message.
      Support for new abort logic.
      Update required firmware revision to 4.0.0.
