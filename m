From: David Miller <davem@davemloft.net>
Subject: Re: [linux-nics] linux-next: Tree for Aug 11
 (net/ethernet/intel/i40e)
Date: Mon, 11 Aug 2014 14:54:54 -0700 (PDT)
Message-ID: <20140811.145454.185028525560881583.davem@davemloft.net>
References: <20140811155213.0aa083ce@canb.auug.org.au>
	<53E8ECA9.6060806@infradead.org>
	<1407786786.2189.0.camel@jtkirshe-mobl.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdunlap@infradead.org, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux.nics@intel.com,
	linux-kernel@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1407786786.2189.0.camel@jtkirshe-mobl.jf.intel.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 11 Aug 2014 12:53:06 -0700

> On Mon, 2014-08-11 at 09:17 -0700, Randy Dunlap wrote:
>> On 08/10/14 22:52, Stephen Rothwell wrote:
>> > Hi all,
>> > 
>> > Please do not add code intended for v3.18 until after v3.17-rc1 is
>> > released.
>> > 
>> > Changes since 20140808:
>> > 
>> 
>> on i386 and x86_64:
>> 
>> ../drivers/net/ethernet/intel/i40e/i40e_fcoe.c: In function
>> 'i40e_get_fcoe_tc_map':
>> ../drivers/net/ethernet/intel/i40e/i40e_fcoe.c:354:23: error:
>> 'IEEE_8021QAZ_APP_SEL_ETHERTYPE' undeclared (first use in this
>> function)
>>    if (app.selector == IEEE_8021QAZ_APP_SEL_ETHERTYPE &&
>> 
>> 
>> Needs to #include <uapi/linux/dcbnl.h> ??
> 
> Yeah, Dave has already accepted a patch to resolve that, which I believe
> went into his net tree.

I see no such change in my tree.
