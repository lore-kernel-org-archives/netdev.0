From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] [PATCH 14/14 v2] nes: kernel build infrastructure
Date: Sun, 21 Oct 2007 19:22:27 -0700
Message-ID: <adave8z99cs.fsf@cisco.com>
References: <200710192028.l9JKSnZG021867@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ewg@lists.openfabrics.org,
	general@lists.openfabrics.org
To: ggrundstrom@neteffect.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <200710192028.l9JKSnZG021867@neteffect.com>
	(ggrundstrom@neteffect.com's message of "Fri,
	19 Oct 2007 15:28:49 -0500")
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

 > +
 > +EXTRA_CFLAGS += -DNES_MINICM

I don't see anyplace NES_MINICM is used.  Delete this line?

 > +
 > +obj-$(CONFIG_INFINIBAND_NES) += iw_nes.o
 > +
 > +iw_nes-objs := nes.o nes_hw.o nes_nic.o nes_utils.o nes_verbs.o nes_cm.o
 > +

Also the file has an extra blank line at the beginning and end.  Might
as well kill them.
