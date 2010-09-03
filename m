From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Thu, 02 Sep 2010 19:16:47 -0700 (PDT)
Message-ID: <20100902.191647.258116956.davem@davemloft.net>
References: <20100903114750.3d8994b7.sfr@canb.auug.org.au>
	<20100903115226.52d0ccb3.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, peppe.cavallaro@st.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100903115226.52d0ccb3.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 3 Sep 2010 11:52:26 +1000

> Hi all,
> 
> On Fri, 3 Sep 2010 11:47:50 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>>
>> Exposed by commit ac75791aa943c7953521cb4fa7728bf51f9abd2d ("stmmac:
>> remove dead option in the driver's Kconfig")  That allowed the driver to
>> be built on a lot more platforms that previously.
> 
> That commit was the result of the only platform that this driver was ever
> used on being removed by commit f96691872439ab2071171d4531c4a95b5d493ae5
> ("sh: Kill off the remaining ST40 cruft").  So maybe this driver should
> actually be removed from the tree as well?

That's up to whoever maintains this thing, well... there is no listed
maintainer in MAINTAINERS.
