From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [3/9] ieee80211: fix ipw 64bit compilation warnings
Date: Mon, 06 Jun 2005 14:29:52 +0800
Message-ID: <1118039392.5702.30.camel@debian.sh.intel.com>
References: <20050603182625.64d33be3@griffin.suse.cz>
	 <20050603183048.7786f98b@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>,
        Jirka Bohac <jbohac@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20050603183048.7786f98b@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-06-03 at 18:30 +0200, Jiri Benc wrote:
> @@ -508,7 +508,7 @@
>  		/* verify we have enough room to store the value */
>  		if (*len < sizeof(u32)) {
>  			IPW_DEBUG_ORD("ordinal buffer length too small, "
> -				      "need %d\n", sizeof(u32));
> +				      "need %d\n", (int)sizeof(u32));

("%zd", sizeof()) should be better.

Thanks,
-yi
