From: jamal <hadi@cyberus.ca>
Subject: Re: cls_u32 compile failure in current 2.6.12-rc1+BK tree
Date: 29 Mar 2005 15:51:56 -0500
Message-ID: <1112129516.1076.90.camel@jzny.localdomain>
References: <Pine.SOC.4.61.0503281017060.21333@math.ut.ee>
	 <1112012657.1089.1013.camel@jzny.localdomain>
	 <20050328123801.GY3086@postel.suug.ch>
	 <1112014261.1089.1018.camel@jzny.localdomain>
	 <20050328125802.GZ3086@postel.suug.ch>
	 <1112015725.1089.1045.camel@jzny.localdomain>
	 <20050328155523.GD3086@postel.suug.ch>
	 <1112038128.1119.5.camel@jzny.localdomain>
	 <20050328195320.GE3086@postel.suug.ch>
	 <20050328223310.GH3086@postel.suug.ch>
	 <20050329011058.GJ3086@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Meelis Roos <mroos@linux.ee>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050329011058.GJ3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


In general (from 1 mile away looks fine).
One issue: a->type could be used for in the future to carry
other things in addition to backward compatibility. So you cant assume
it being set means only backward compat is needed (and nothing else).

cheers,
jamal

On Mon, 2005-03-28 at 20:10, Thomas Graf wrote:
> * Thomas Graf <20050328223310.GH3086@postel.suug.ch> 2005-03-29 00:33
> > We dump TCA_ACT_STATS in tcf_exts_dump and handle all the backward
> > compibility including dumping policer stats in tcf_exts_dump_stats.
> > This means we have to adapt gnet_stats a bit to allow for this.
> 
> Attached patches is what I meant. Untested but you should get
> the idea.
