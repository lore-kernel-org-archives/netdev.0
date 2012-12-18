From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 11/11] bridge: Dump vlan information from a bridge port
Date: Tue, 18 Dec 2012 12:51:24 -0500
Message-ID: <50D0AD1C.4020506@redhat.com>
References: <1355342477-4971-1-git-send-email-vyasevic@redhat.com> <1355342477-4971-12-git-send-email-vyasevic@redhat.com> <20121218090332.2f18f393@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mst@redhat.com,
	john.r.fastabend@intel.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299Ab2LRRva (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 12:51:30 -0500
In-Reply-To: <20121218090332.2f18f393@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/2012 12:03 PM, Stephen Hemminger wrote:
> On Wed, 12 Dec 2012 15:01:17 -0500
> Vlad Yasevich <vyasevic@redhat.com> wrote:
>
>> Using the RTM_GETLINK dump the vlan filter list of a given
>> bridge port.  The information depends on setting the filter
>> flag similar to how nic VF info is dumped.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>
> I will put these in the bridge tree with other patches that
> are being staged for net-next.
>

Hold on a bit.  I was running some more tests and found some
scenarios that didn't work right.

I am preparing v2 of the patches.

Thanks
-vlad
