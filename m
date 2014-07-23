From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: network interfaces called "all", "default" or "config"
Date: Wed, 23 Jul 2014 07:56:38 -0700
Message-ID: <53CFCD26.1020409@infradead.org>
References: <20140723113314.GA7798@chaz.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephane Chazelas <stephane.chazelas@gmail.com>,
	linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140723113314.GA7798@chaz.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[adding netdev]

On 07/23/2014 04:33 AM, Stephane Chazelas wrote:
> Hiya,
> 
> you may want to forbid the creation of interfaces whose name is
> one of the special files in /proc/net and /proc/sys.
> 
> I can see some characters (like space, tab, newline, slash,
> dot...) are alread forbidden in interface names (EINVAL), but
> one can do for instance:
> 
> sudo ip link add link eth0 all type vlan id 2
> sudo ip link add link eth0 default type vlan id 3
> sudo ip link add link eth0 config type vlan id 4
> 
> Interestingly, after you add a "all" or "default", the
> corresponding /proc/sys/net/ipv[46]/conf/(all|default) become
> empty, and remain so even after you've removed the interface.
> 
> Adding an interface called "config" masks /proc/net/vlan/config
> 
> (tested with 3.14-1-amd64 on debian)
> 


-- 
~Randy
