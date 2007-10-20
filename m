From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 2/14 v2] nes: device structures and defines
Date: Fri, 19 Oct 2007 22:22:44 -0700
Message-ID: <adaabqebbrv.fsf@cisco.com>
References: <200710192004.l9JK48dm021704@neteffect.com>
	<20071019220015.3faa9bbb@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ewg@lists.openfabrics.org,
	general@lists.openfabrics.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071019220015.3faa9bbb@freepuppy.rosehill> (Stephen Hemminger's
	message of "Fri, 19 Oct 2007 22:00:15 -0700")
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

 > You are starting off on the wrong foot.

???

 > > +if(!(expr)) {														\
 > > +	printk(KERN_ERR PFX "Assertion failed! %s, %s, %s, line %d\n",	\
 > > +		   #expr, __FILE__, __FUNCTION__, __LINE__);				\
 > > +}
 > 
 > Use BUG_ON

I agree that there's no need to invent a driver-private assertion
macro, but (to first order at least) drivers should never use BUG_ON.
I don't want some glitch in a network driver that the system could
probably survive to be turned into a panic by BUG_ON -- WARN_ON seems
infinitely preferable.

 - R.
