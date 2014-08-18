From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] drivers: net: ethernet: intel: e1000: e1000_ethtool.c
 coding style fixes
Date: Mon, 18 Aug 2014 08:45:53 -0700
Message-ID: <53F21FB1.7060607@intel.com>
References: <1408180328-4827-1-git-send-email-cristos@vipserv.org>	 <1408214489.2683.87.camel@joe-AO725> <53F21BEC.2070204@intel.com> <1408375914.2741.1.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:16627 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750789AbaHRPqL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2014 11:46:11 -0400
In-Reply-To: <1408375914.2741.1.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/2014 08:31 AM, Joe Perches wrote:
> On Mon, 2014-08-18 at 08:29 -0700, Alexander Duyck wrote:
>> Doing any kind of pointer math on a void pointer is generally unsafe as
>> it is an incomplete type.  The only reason why it works in GCC is
>> because GCC has a nonstandard extension that makes it report as having a
>> size of 1.
> 
> I know.  It's used in quite a few places in kernel code
> so I believe it's now a base assumption for the kernel.

Well that is something that should probably be fixed then.  I don't
believe it is safe to be doing any kind of pointer math on a void pointer.

We really shouldn't be using any GCC specific bits unless we absolutely
have to.

Thanks,

Alex
