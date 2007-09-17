From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [ofa-general] Re: [PATCH v2] iw_cxgb3: Support "iwarp-only"
	interfaces to avoid 4-tuple conflicts.
Date: Mon, 17 Sep 2007 20:17:07 +0400
Message-ID: <20070917161706.GA28431@2ka.mipt.ru>
References: <20070913191617.30937.95960.stgit@dell3.ogc.int>
	<20070914130941.GG18517@2ka.mipt.ru>
	<46EC00BE.3020801@opengridcomputing.com>
	<46EEA6A2.2080001@ichips.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rdreier@cisco.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: Sean Hefty <mshefty@ichips.intel.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <46EEA6A2.2080001@ichips.intel.com>
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

On Mon, Sep 17, 2007 at 09:09:06AM -0700, Sean Hefty (mshefty@ichips.intel.com) wrote:
> >>>+    addr = kmalloc(sizeof *addr, GFP_KERNEL);
> >>
> >>As a small nitpick: this wants to be sizeof(struct in_ifaddr)
> 
> See chapter 14 of CodingStyle document.  kmalloc(sizeof *addr... is correct.

Come on, do not start a flame war about how parameters into kmalloc
should be provided - there are much more serious issues unresolved yes. It
does help grepping the code, but if you feel that this is a serious threat,
then use your preferred way.

-- 
	Evgeniy Polyakov
