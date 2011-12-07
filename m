From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] e1000e: Assign true and false to bool
 type variable instead of 1 and 0
Date: Wed, 07 Dec 2011 17:15:42 +0800
Message-ID: <4EDF2EBE.2060708@linux.vnet.ibm.com>
References: <4EDED071.40900@linux.vnet.ibm.com>
	<1323229439.2415.23.camel@jtkirshe-mobl>
	<1323231268.1762.19.camel@joe2Laptop>
	<4EDEF05F.4020901@linux.vnet.ibm.com>
	<1323237700.1762.24.camel@joe2Laptop>
	<4EDF02CC.4010407@linux.vnet.ibm.com>
	<1323238749.1762.27.camel@joe2Laptop>
	<4EDF0964.3080509@linux.vnet.ibm.com>
	<1323248664.2415.28.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"wangyunlinux@gmail.com" <wangyunlinux@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1323248664.2415.28.camel@jtkirshe-mobl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 12/07/2011 05:04 PM, Jeff Kirsher wrote:

> On Tue, 2011-12-06 at 22:36 -0800, Michael Wang wrote:
>> On 12/07/2011 02:19 PM, Joe Perches wrote:
>>
>>> On Wed, 2011-12-07 at 14:08 +0800, Michael Wang wrote:
>>>> I'm not good at script, if you are interested, we can work together
>> to
>>>> fix all the remain cases, and send out some patches.
>>>
>>> You should try coccinelle and spatch.
>>>
>>
>> Hi, Joe
>>
>> I have not used coccinelle and spatch before, I will study on them
>> later.
>>
>>> If you run the script, this is the intel output.
>>>
>>>  drivers/net/ethernet/intel/e1000/e1000_main.c |   10 +++++-----
>>>  drivers/net/ethernet/intel/ixgb/ixgb_main.c   |    2 +-
>>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
>>>  drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  |    4 ++--
>>>  4 files changed, 9 insertions(+), 9 deletions(-)
>>
>>
>> We can try to fix them, thanks for the suggestion.
>>
>> Regards,
>> Michael Wang 
> 
> So should I expect a v3 of this patch?
> 

Hi, Jeff

Please use the v2 first, because what Joe described will have a
different meaning and edit different files.

> Also I am fine with lumping all the changes for all our drivers in one
> patch as long as the changes for each driver are somewhat small.  If the
> changes for a particular driver gets too extensive, please create a
> separate patch.


I think separate such patch according to files will be better.

Thanks,
Michael Wang

> 
> Cheers,
> Jeff



------------------------------------------------------------------------------
Cloud Services Checklist: Pricing and Packaging Optimization
This white paper is intended to serve as a reference, checklist and point of 
discussion for anyone considering optimizing the pricing and packaging model 
of a cloud services business. Read Now!
http://www.accelacomm.com/jaw/sfnl/114/51491232/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
