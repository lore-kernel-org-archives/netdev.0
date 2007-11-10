From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/2]: e1000: avoid lockup durig error
	recovery
Date: Sat, 10 Nov 2007 08:55:19 -0800
Message-ID: <20071110085519.0b430069@shemminger-laptop>
References: <20071107211935.GH4239@austin.ibm.com> <47323FFE.2060008@intel.com>
	<20071107232119.GQ4239@austin.ibm.com>
	<200711091802.36365.netdev@axxeo.de>
	<20071109224005.GQ4239@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	NetDev <netdev@vger.kernel.org>,
	"Brandeburg,  Jesse" <jesse.brandeburg@intel.com>,
	Ingo Oeser <netdev@axxeo.de>, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, wenxiong@us.ibm.com
To: linas@austin.ibm.com (Linas Vepstas)
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20071109224005.GQ4239@austin.ibm.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 9 Nov 2007 16:40:05 -0600
linas@austin.ibm.com (Linas Vepstas) wrote:

> On Fri, Nov 09, 2007 at 06:02:34PM +0100, Ingo Oeser wrote:
> > Linas Vepstas schrieb:
> > > + *	napi_enabled_p - return non-zero if napi enabled
> > > + * 
> > > + * Mnemonic: _p stands for "predicate", returning a yes/no
> > > + * answer to the question.
> > 
> > Call it "is_napi_enabled()" an nobody will ask :-)
> 
> Heh. The suffix _p is standard coding style for lisp/scheme
> and first-order logic interpreters.  This was my lame attempt
> to introduce it to the kernel. I guess that lame duck won't fly.
> 
> --linas
> 

NO.  it reeks of hungarian notation.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
