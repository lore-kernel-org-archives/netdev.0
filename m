From: Joe Perches <joe@perches.com>
Subject: Re: [net] checkpatch: modify logFunction regular expression to
 allow repeated front tags
Date: Wed, 19 Jun 2013 06:42:03 -0700
Message-ID: <1371649323.2038.23.camel@joe-AO722>
References: <1371638323-20999-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: apw@canonical.com, Jacob Keller <jacob.e.keller@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371638323-20999-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-19 at 03:38 -0700, Jeff Kirsher wrote:
> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> The previous logFunction regular expression allowed names for log functions like
> dev_warn or e_dbg and so forth, but some log functions are of the forms
> similar to e_dev_warn, (adding an additional tag in front of a standard name
> like dev_warn).

Perhaps names like foo_bar_baz_dev_warn are a bit long.

Maybe instead of
+	(?:[a-z0-9]+_)+(?:printk|emerg|alert|crit|err|warning|warn|notice|info|debug|dbg|vdbg|devel|cont|WARN)(?:_ratelimited|_once|)|
use
+	(?:[a-z0-9]+_){0,2}(?:printk|emerg|alert|crit|err|warning|warn|notice|info|debug|dbg|vdbg|devel|cont|WARN)(?:_ratelimited|_once|)|
