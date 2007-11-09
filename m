From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 2/2]: e1000: avoid lockup durig error
	recovery
Date: Fri, 9 Nov 2007 18:02:34 +0100
Message-ID: <200711091802.36365.netdev@axxeo.de>
References: <20071107211935.GH4239@austin.ibm.com> <47323FFE.2060008@intel.com>
	<20071107232119.GQ4239@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	NetDev <netdev@vger.kernel.org>,
	"Brandeburg,  Jesse" <jesse.brandeburg@intel.com>,
	john.ronciak@intel.com, jeffrey.t.kirsher@intel.com,
	'Stephen Hemminger' <shemminger@linux-foundation.org>,
	wenxiong@us.ibm.com
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20071107232119.GQ4239@austin.ibm.com>
Content-Disposition: inline
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

Hi Linas,

Linas Vepstas schrieb:
> Index: linux-2.6.23-rc8-mm1/include/linux/netdevice.h
> ===================================================================
> --- linux-2.6.23-rc8-mm1.orig/include/linux/netdevice.h	2007-09-26 15:07:05.000000000 -0500
> +++ linux-2.6.23-rc8-mm1/include/linux/netdevice.h	2007-11-07 17:14:50.000000000 -0600
> @@ -384,6 +384,18 @@ static inline void napi_enable(struct na
>  	clear_bit(NAPI_STATE_SCHED, &n->state);
>  }
>  
> +/**
> + *	napi_enabled_p - return non-zero if napi enabled
> + *	@n: napi context
> + * 
> + * Mnemonic: _p stands for "predicate", returning a yes/no
> + * answer to the question.

Call it "is_napi_enabled()" an nobody will ask :-)

> + */
> +static inline int napi_enabled_p(struct napi_struct *n)

And please make it return "bool" instead of "int".


Best Regards

Ingo Oeser

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
