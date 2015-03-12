From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V1 0/3] net/mlx4_core: Allow setting init-time
 device specific parameters
Date: Thu, 12 Mar 2015 14:02:05 +0200
Message-ID: <5501803D.8020101@mellanox.com>
References: <1426064933-29072-1-git-send-email-amirv@mellanox.com>
 <20150311.131457.1314699780103858026.davem@davemloft.net>
 <CAJL1qvHP0cLRVf53J9MuJrYCJLjE=mzEU70JofJ8zH_Yf-O16g@mail.gmail.com>
 <20150312090042.GB1092@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	<yevgenyp@mellanox.com>, Tal Alon <talal@mellanox.com>,
	<shannon.nelson@intel.com>, <dledford@redhat.com>,
	<greearb@candelatech.com>, <gregory.v.rose@intel.com>,
	<jeffrey.t.kirsher@intel.com>, <jesse.brandeburg@intel.com>,
	<john.ronciak@intel.com>
To: Greg KH <gregkh@linuxfoundation.org>,
	Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0077.outbound.protection.outlook.com ([157.56.112.77]:55508
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751370AbbCLMCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 08:02:36 -0400
In-Reply-To: <20150312090042.GB1092@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/12/2015 11:00 AM, Greg KH wrote:
> On Thu, Mar 12, 2015 at 10:07:35AM +0200, Hadar Hen Zion wrote:
>> On Wed, Mar 11, 2015 at 7:14 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Amir Vadai <amirv@mellanox.com>
>>> Date: Wed, 11 Mar 2015 11:08:50 +0200
>>>
>>>> Also, customers are paying for a very sophisticated piece of hardware, and we would like to enable power user to tweak it in some situtations. Of course the default mode should be used in 99% of the use cases.
>>> How much money someone pays for your hardware has nothing to do with the standards by which we design userspace interfaces to configure these devices.
>>>
>>> These textual interfaces are arbitrary, and you are choosing it only because you cannot come up with a more reasonable scheme,
>>>
>>> I'm not applying these changes.
>>> ---
>> In previous conversations Greg suggested us to use configfs.
>>
>> Is this case a misuse of configfs? maybe configfs should be deprecated... Greg?
> No, this has nothing to do with the validity of configfs, please re-read what David said to you.

Greg,

So.. M2-- reading Dave's words I understand that he's against textual 
interfacessuch as configfs and prefers others. This brings two questions 
to the table (1) do we need to deprecate these textual interfaces / 
configfs and avoid using them for configuration purposes with new code? 
(2) does programmable interface such as netlink is the way to go for our 
purposes here (and elsewhere)?

Or.
