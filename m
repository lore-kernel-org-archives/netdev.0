From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 2.6.21] iw_cxgb3 - Add set_tcb_rpl_handler.
Date: Thu, 12 Apr 2007 09:07:20 -0700
Message-ID: <ada3b35ink7.fsf@cisco.com>
References: <1176382594.9396.1.camel@stevo-desktop>
	<461E45C3.2050400@chelsio.com> <adaveg1ipki.fsf@cisco.com>
	<1176392566.9396.11.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	OpenFabrics General <general@lists.openfabrics.org>,
	linux-kernel <linux-kernel@vger.kernel.org>, Divy Le Ray <divy@chelsio.com>
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1176392566.9396.11.camel@stevo-desktop> (Steve Wise's message of
	"Thu, 12 Apr 2007 10:42:46 -0500")
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

 > The patch is the 3rd of 3:
 > 
 > http://marc.info/?l=linux-kernel&m=117617444622279&w=2
 > 
 > Jeff applied it into his upstream tree here:
 > 
 > http://marc.info/?l=linux-netdev&m=117630664627997&w=2

OK, so it's not in Linus's tree yet.  Jeff, how do you want to handle
this?  (That last patch breaks drivers/infiniband/hw/cxgb3, and Steve
posted a fix to handle it)

The cleanest thing would be for you to roll up Steve's fix into the
patch you merged, so that Linus's tree is never in the state where it
has half the change merged.  But I don't know if that fits your
workflow.

Thanks...
