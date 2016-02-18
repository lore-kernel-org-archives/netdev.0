From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net, thunderx: Use bool in structs where possible
Date: Thu, 18 Feb 2016 15:06:31 -0500 (EST)
Message-ID: <20160218.150631.574392083739567663.davem@davemloft.net>
References: <1455799149-19590-3-git-send-email-rrichter@caviumnetworks.com>
	<20160218.110514.652169911099659792.davem@davemloft.net>
	<20160218164217.GP24726@rric.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgoutham@cavium.com, rric@kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: robert.richter@caviumnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160218164217.GP24726@rric.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Richter <robert.richter@caviumnetworks.com>
Date: Thu, 18 Feb 2016 17:42:17 +0100

> On 18.02.16 11:05:14, David Miller wrote:
>> From: Robert Richter <rrichter@caviumnetworks.com>
>> Date: Thu, 18 Feb 2016 13:39:09 +0100
>> 
>> > From: Robert Richter <rrichter@cavium.com>
>> > 
>> > Looks like the :1 notation was accidentally introduced (this still
>> > uses 1 byte per flag). Using bool instead, which is the common use.
>> > 
>> > Signed-off-by: Robert Richter <rrichter@cavium.com>
>> 
>> Such cleanups are not appropriate for 'net'.  Only real bug fixes should
>> be targetted that.
>> 
>> Respin these patches targetting the correct tree(s).
> 
> Do you mean posting the two as "trivial" patches?

No I mean posting #1 targetted at my 'net' GIT tree as a bug fix,
and posting #2 targetted separately at my 'net-next' GIT tree as
a cleanup.

This is how we've been doing things for more than a decade.
