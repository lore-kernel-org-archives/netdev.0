From: Florian Fainelli <ffainelli@freebox.fr>
Subject: Re: [PATCH 1/2] e1000: unmap ce4100_gbe_mdio_base_virt in e1000_remove
Date: Fri, 06 Jan 2012 15:21:22 +0100
Message-ID: <4F070362.2080703@freebox.fr>
References: <1323276062-10906-1-git-send-email-ffainelli@freebox.fr>  <1323295282.2415.36.camel@jtkirshe-mobl> <4F04A205.4040908@freebox.fr> <1325713307.2718.35.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:45968 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755989Ab2AFOV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jan 2012 09:21:28 -0500
In-Reply-To: <1325713307.2718.35.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/04/12 22:41, Jeff Kirsher wrote:
> On Wed, 2012-01-04 at 20:01 +0100, Florian Fainelli wrote:
>> Hello Jeff,
>>
>> On 12/07/11 23:01, Jeff Kirsher wrote:
>>> On Wed, 2011-12-07 at 08:41 -0800, Florian Fainelli wrote:
>>>> We are not unmapping ce4100_gbe_mdio_base_virt in exit path in case
>>>> we are running on a CE4100 adapter, fix that.
>>>>
>>>> Signed-off-by: Florian Fainelli<ffainelli@freebox.fr>
>>>> ---
>>>>    drivers/net/ethernet/intel/e1000/e1000_main.c |    2 ++
>>>>    1 files changed, 2 insertions(+), 0 deletions(-)
>>>
>>> Thanks Florian, I have added your two patches to my queue.
>>
>> I have not seen these patches in the last "Intel Wired LAN" pull requets
>> that you did, are you holding them for a later pull request?
>>
>> Thanks.
>> --
>> Florian
>>
>
> Yes, I apologize and had overlooked your patches when putting together
> the last to pull requests.  I will make sure they are in the one of the
> next 2 pull requests.

I just saw them, thanks Jeff!
--
Florian
