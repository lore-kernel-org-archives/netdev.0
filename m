From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net] checkpatch: modify logFunction regular expression to
 allow repeated front tags
Date: Wed, 19 Jun 2013 22:06:26 +0000
Message-ID: <02874ECE860811409154E81DA85FBB585650A046@ORSMSX104.amr.corp.intel.com>
References: <1371638323-20999-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1371649323.2038.23.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "apw@canonical.com" <apw@canonical.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371649323.2038.23.camel@joe-AO722>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Wednesday, June 19, 2013 6:42 AM
> To: Kirsher, Jeffrey T
> Cc: apw@canonical.com; Keller, Jacob E; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org
> Subject: Re: [net] checkpatch: modify logFunction regular expression to
> allow repeated front tags
> 
> On Wed, 2013-06-19 at 03:38 -0700, Jeff Kirsher wrote:
> > From: Jacob Keller <jacob.e.keller@intel.com>
> >
> > The previous logFunction regular expression allowed names for log
> functions like
> > dev_warn or e_dbg and so forth, but some log functions are of the
> forms
> > similar to e_dev_warn, (adding an additional tag in front of a standard
> name
> > like dev_warn).
> 
> Perhaps names like foo_bar_baz_dev_warn are a bit long.
> 
> Maybe instead of
> +	(?:[a-z0-
> 9]+_)+(?:printk|emerg|alert|crit|err|warning|warn|notice|info|debug
> |dbg|vdbg|devel|cont|WARN)(?:_ratelimited|_once|)|
> use
> +	(?:[a-z0-
> 9]+_){0,2}(?:printk|emerg|alert|crit|err|warning|warn|notice|info|de
> bug|dbg|vdbg|devel|cont|WARN)(?:_ratelimited|_once|)|
> 

That sounds good to me.

- Jake
