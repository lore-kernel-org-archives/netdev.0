From: Jan Blunck <jblunck@infradead.org>
Subject: Re: [PATCH] ipv6: no addrconf for slave devices
Date: Fri, 16 Oct 2015 18:36:01 +0200
Message-ID: <CALe+Z01M7RktfbNvR3rcUC_EMGN2zEjNOHScgo8B-bNrActFrQ@mail.gmail.com>
References: <1444990911-27458-1-git-send-email-jblunck@infradead.org>
	<20151016115457.GE2194@nanopsycho.orion>
	<CALe+Z02xUZEeRMBfTneJaGFH0TQFoQt9WcJ67ogbQwXEs6p8Ew@mail.gmail.com>
	<56211FA7.6020107@cumulusnetworks.com>
	<CALe+Z02gaON+Zan0HbL6X3omwiVYEd4-uayA8sQ+BQmU3x7V0g@mail.gmail.com>
	<56212256.8090704@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	fubar@us.ibm.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56212256.8090704@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 16, 2015 at 6:14 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 10/16/15 10:12 AM, Jan Blunck wrote:
>>
>> On Fri, Oct 16, 2015 at 6:02 PM, David Ahern <dsa@cumulusnetworks.com>
>> wrote:
>>>
>>> On 10/16/15 9:57 AM, Jan Blunck wrote:
>>>>
>>>>
>>>>
>>>> I don't think that enslaved ports should get network layer addresses.
>>>> This is one example with a team device:
>>>
>>>
>>>
>>> for VRF devices we do want the enslaved links to have link local
>>> addresses.
>>>
>>
>> That is interesting. As far I can see you are setting IFF_SLAVE in
>> do_vrf_add_slave() and therefore already stop IPv6 addrconf.
>>
>
> Check net-next. That had to be removed to get IPv6 working.
>

Thanks for the pointer.

So it would be better to differentiate between L2 and L3 ports and
only start addrconf on later ones? I don't think there is a flag that
allows for that though.
