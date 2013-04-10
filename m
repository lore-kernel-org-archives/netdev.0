From: Ben Greear <greearb@candelatech.com>
Subject: Re: Jitter and latency benchmarks with netlink / nl80211
Date: Wed, 10 Apr 2013 11:10:08 -0700
Message-ID: <5165AB00.2000605@candelatech.com>
References: <CAB=NE6XH8wGbFhmB54Y0BUB2N-PbzUBvN+arH5F_BAkEa=DjUw@mail.gmail.com> <5165A874.50804@candelatech.com> <CAB=NE6U_0E+y8jc_0O3+9pmUyLXX9CuSMYMMWk__4Q8-+-AHTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6U_0E+y8jc_0O3+9pmUyLXX9CuSMYMMWk__4Q8-+-AHTg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/10/2013 11:05 AM, Luis R. Rodriguez wrote:
> On Wed, Apr 10, 2013 at 10:59 AM, Ben Greear <greearb@candelatech.com> wrote:
>> On 04/10/2013 10:55 AM, Luis R. Rodriguez wrote:
>>>
>>> Curious if anyone has worked on latency and jitter benchmarks in using
>>> netlink, specifically with nl80211. Has anyone benchmarked this? Ben,
>>> have you? If not for nl80211 perhaps this has been done before for
>>> other netlink families?
>>
>>
>> You mean timing related to netlink configuration/report requests?
>
> Yes.

No, I haven't bothered to do this...  The way we use netlink is
mostly asynchronous..ie we just listen for events and process them
as they come in.  Most of our configuration would be driven through 'iw',
'wpa_supplicant', 'ip', etc, and much of our stats gathering is through
the ethool get-stats API.

I would imagine any latency would be highly dependent on other applications
taking RTNL (for instance, creating/deleting lots of virtual stations,
mac-vlans, ip-address changes, etc).

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
