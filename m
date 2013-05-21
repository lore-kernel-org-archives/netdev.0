From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 3/4] ixgbe: Add support for ndo_ll_poll
Date: Tue, 21 May 2013 01:39:12 -0700 (PDT)
Message-ID: <20130521.013912.96249995742935192.davem@davemloft.net>
References: <1369120003.25971.2.camel@lb-tlvb-eilong.il.broadcom.com>
	<20130521.001444.1361294042663568537.davem@davemloft.net>
	<CAJZOPZJTA9A8T4R8MtRCeqcYj3XJWFCXF+ojmEqza5TMj-6G+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, eliezer.tamir@linux.intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, donald.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	andi@firstfloor.org, hpa@zytor.com, eliezer@tamir.org.il
To: or.gerlitz@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJZOPZJTA9A8T4R8MtRCeqcYj3XJWFCXF+ojmEqza5TMj-6G+w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Tue, 21 May 2013 11:24:41 +0300

> On Tue, May 21, 2013 at 10:14 AM, David Miller <davem@davemloft.net> wrote:
>> From: "Eilon Greenstein" <eilong@broadcom.com>
>> Date: Tue, 21 May 2013 10:06:43 +0300
>>
>>> Hopefully this series will be accepted so we can send follow up support
>>> for the bnx2x as well.
>>
>> I think in two or three more iterations it will be merged.
>>
>> There are no objections on the fundamentals, it's just implementation
>> details and coding style at this point.
> 
> Dave, sorry, I might be a bit behind the rest of the reviewers, but I
> just fail to understand nor find any reference that explains the
> module param of ixgbe nor it makes sense to me to merge that piece of
> the code upstream (its not for staging, correct?), as I wrote here
> http://marc.info/?l=linux-netdev&m=136908123432072&w=2 basically, I
> know you're not a great fun of module params (to say the least) and
> surely not something named  "allow_unsafe_removal", thoughts?

It's one of those "implementation details", I hate it too.
