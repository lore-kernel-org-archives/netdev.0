From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 09 Jun 2005 18:21:35 -0400
Message-ID: <1118355695.12573.34.camel@localhost.localdomain>
References: <468F3FDA28AA87429AD807992E22D07E0450C01F@orsmsx408>
	 <20050607.132159.35660612.davem@davemloft.net>
	 <Pine.LNX.4.62.0506071852290.31708@ladlxr>
	 <20050607.204339.21591152.davem@davemloft.net>
	 <1118237775.6382.34.camel@localhost.localdomain>
	 <Pine.LNX.4.62.0506091406590.10396@ladlxr>
	 <20050609150546.61b0fee7@unknown-215.office.pdx.osdl.net>
	 <Pine.LNX.4.62.0506091510560.16917@ladlxr>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>,
        "Ronciak, John" <john.ronciak@intel.com>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, mchan@broadcom.com,
        buytenh@wantstofly.org, jdmason@us.ibm.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.LNX.4.62.0506091510560.16917@ladlxr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-09-06 at 15:12 -0700, Jesse Brandeburg wrote:
> On Thu, 9 Jun 2005, Stephen Hemminger wrote:
> > > 313667    4.7884  vmlinux          csum_partial
> > > 218870    3.3413  vmlinux          _spin_lock
> > > 214302    3.2715  vmlinux          __copy_user_intel
> > > 193662    2.9564  vmlinux          skb_release_data
> > > 177755    2.7136  vmlinux          ipt_do_table
> > 
> > You are probably benchmarking iptables/netfilter! How many rules do you
> > have?
> 
> I saw that... somehow iptables got compiled into kernel statically.  no 
> rules are active or installed  iptables -L -n shows nothing in any chain.

Contracking is a lot worse of a problem. Just turn off netfilter all
together.

cheers,
jamal
