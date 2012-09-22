From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH V2 net-next 4/4] ptp: clarify the clock_name sysfs attribute
Date: Sat, 22 Sep 2012 09:03:47 -0700
Message-ID: <505DE163.1030809@gmail.com>
References: <cover.1348299094.git.richardcochran@gmail.com>  <6bc914f0607428ab0d8f5d5fc42a5e87bedc95c5.1348299094.git.richardcochran@gmail.com> <1348328688.2521.81.camel@bwh-desktop.uk.solarflarecom.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24976 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751627Ab2IVQDt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2012 12:03:49 -0400
In-Reply-To: <1348328688.2521.81.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2012 08:44 AM, Ben Hutchings wrote:
> On Sat, 2012-09-22 at 09:42 +0200, Richard Cochran wrote:
>> There has been some confusion among PHC driver authors about the
>> intended purpose of the clock_name attribute. This patch expands the
>> documation in order to clarify how the clock_name field should be
>> understood.
>>
>> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
>> ---
>>   Documentation/ABI/testing/sysfs-ptp |    5 ++++-
>>   1 files changed, 4 insertions(+), 1 deletions(-)
>>
>> diff --git a/Documentation/ABI/testing/sysfs-ptp b/Documentation/ABI/testing/sysfs-ptp
>> index d40d2b5..c906488 100644
>> --- a/Documentation/ABI/testing/sysfs-ptp
>> +++ b/Documentation/ABI/testing/sysfs-ptp
>> @@ -19,7 +19,10 @@ Date:		September 2010
>>   Contact:	Richard Cochran <richardcochran@gmail.com>
>>   Description:
>>   		This file contains the name of the PTP hardware clock
>> -		as a human readable string.
>> +		as a human readable string. The purpose of this
>> +		attribute is to provide the user with a "friendly
>> +		name" and to help distinguish PHY based devices from
>> +		MAC based ones.
> Might also be worth saying that it is not required to be unique.  And
> this explanation should also go in the kernel-doc in ptp_clock_kernel.h,
> which is what driver writers are most likely to read.
>
> Ben
FWIW, I agree with Ben.
