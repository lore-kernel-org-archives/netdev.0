From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [patch net-next] cxgb3: update firmware version
Date: Mon, 13 Feb 2012 20:49:13 -0800
Message-ID: <4F39E7C9.20901@chelsio.com>
References: <20120213202846.631.30806.stgit@speedy5.asicdesigners.com> <1329165817.2092.62.camel@shinybook.infradead.org> <4F398303.1030606@chelsio.com> <1329184754.3048.33.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>, nhorman@tuxdriver.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329184754.3048.33.camel@deadeye>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, February 13, 2012 5:59:14 PM, Ben Hutchings wrote:
>
> On Mon, 2012-02-13 at 13:39 -0800, Divy Le Ray wrote:
>>
>> On Monday, February 13, 2012 12:43:37 PM, David Woodhouse wrote:
>>>
>>>
>>> On Mon, 2012-02-13 at 12:28 -0800, Divy Le Ray wrote:
>>>>
>>>>
>>>> This patch updates the firmware version cxgb3 is requesting to 7.12.0.
>>>
>>>
>>>
>>> I'm confused. Your patch doesn't change anything in the driver, except
>>> the firmware version. So why is it a "major" change?
>>
>>
>> Hi David,
>>
>> cxgb3 embeds the firmware file name it will request at load time.
>> It uses the FW_VERSION_* defs to construct the firmware name FW_FNAME
>> before calling request_firmware().
>> Hence the need to update the firmware minor version.
>>
>> On the other hand, the driver version update is not a strict requirement
>> here.
>> I would prefer keeping it though.
>
>
> The problems with this are:
> 1. Older kernel versions don't benefit from the firmware update.
> 2. The old firmware has to be kept in linux-firmware to support those
> old kernel versions, and distributions may have to package more
> versions.
>
> To avoid this, the firmware filename should only be changed if you make
> incompatible changes in the driver/firmware interface.

Hi Ben,

The scheme for cxgb3 firmware update was designed in coordination with 
OEMs in the early stages of the driver existence back in 2007.
Committing FW 7.12.0 under the name of t3fw-7.10.0.bin would be 
confusing, in my mind.
Some distributions have explicitly requested the FW rev number to be 
appended to the firmware file name.

Cheers,
Divy
