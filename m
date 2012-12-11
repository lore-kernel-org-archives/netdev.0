From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next 1/2] net: ethtool: Add destination MAC address
 to flow steering API
Date: Tue, 11 Dec 2012 12:57:53 -0800
Message-ID: <50C79E51.1000904@intel.com>
References: <1355227436-18383-1-git-send-email-amirv@mellanox.com> <1355227436-18383-2-git-send-email-amirv@mellanox.com> <50C76F6E.2010600@intel.com> <CAJZOPZJfqdrxKp8ZPTXs_-07XSdPoKu+bNQNZzkeTRgP-R2XnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yan Burman <yanb@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47455 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754019Ab2LKU5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2012 15:57:54 -0500
In-Reply-To: <CAJZOPZJfqdrxKp8ZPTXs_-07XSdPoKu+bNQNZzkeTRgP-R2XnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/2012 11:55 AM, Or Gerlitz wrote:
> On Tue, Dec 11, 2012 at 7:37 PM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
>>
>> Is there any special reason why you need to change the size of this
>> structure?  It seems like you could probably just replace the data
>> section with a union containing either 8 bytes of user specified data or
>> your MAC address data.  Then we wouldn't need all of the changes to the
>> rest of the flow specifier.
> 
> 
> basically, we followed Ben's suggestions made here
> http://marc.info/?t=134977576500003
> 

After looking over Ben's suggestion it makes sense.

Since I am pretty much responsible for the ixgbe implementation of this
I will do a few quick tests once the patches are applied to make certain
that there were no issues introduced on our end.

Thanks,

Alex
