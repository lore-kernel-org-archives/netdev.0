From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 13/14 v2] nes: kernel build infrastructure
Date: Sun, 21 Oct 2007 19:23:50 -0700
Message-ID: <adar6jn99ah.fsf@cisco.com>
References: <200710192027.l9JKR197021855@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ewg@lists.openfabrics.org,
	general@lists.openfabrics.org
To: ggrundstrom@neteffect.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <200710192027.l9JKR197021855@neteffect.com>
	(ggrundstrom@neteffect.com's message of "Fri,
	19 Oct 2007 15:27:01 -0500")
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

 > +config INFINIBAND_NES_DEBUG
 > +	bool "Verbose debugging output"
 > +	depends on INFINIBAND_NES
 > +	default n
 > +	---help---
 > +	  This option causes the NetEffect RNIC driver to produce debug
 > +	  messages.  Select this if you are developing the driver
 > +	  or trying to diagnose a problem.

If you make this default n then no distro will have it enabled and
you'll have to rebuild to debug anything.  Better to have the default
be enabled and make it controllable at runtime too with a module
parameter.  (you can look at what mthca does for an example of what I mean)
