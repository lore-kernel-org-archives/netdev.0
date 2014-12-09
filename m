From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [ovs-dev] OVS Kernel Datapath development
Date: Tue, 9 Dec 2014 09:34:33 -0800
Message-ID: <CALnjE+qsj4Z+v7no8Ede5o=zm6F+rTPFpptUCvyCdPStvp+oRw@mail.gmail.com>
References: <CALnjE+rn_Giv+8TM1_E2faBftRkivXMYHcjn-4Eq4Gu15r=CiQ@mail.gmail.com>
	<20141208171506.GC2835@pox.localdomain>
	<CALnjE+p6udF7oPBBjZWcT79iGOWAwLW3eWzEMJw+MX7W3WOjLA@mail.gmail.com>
	<54870E56.30305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@noironetworks.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: thomasfherbert@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog017.obsmtp.com ([74.125.150.74]:44059 "HELO
	na6sys009bog017.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751397AbaLIRhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 12:37:14 -0500
Received: by mail-ie0-f180.google.com with SMTP id rp18so932693iec.25
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 09:34:33 -0800 (PST)
In-Reply-To: <54870E56.30305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 9, 2014 at 6:59 AM, Thomas F Herbert
<thomasfherbert@gmail.com> wrote:
> Thanks.
>
> What is the impact on a developer submitting a patch. Do we now submit the
> linux datapath portion of the patch to both netdev and ovs-dev?
>
Yes, if a feature needs kernel datapath changes the feature series
should be posted on both mailing lists.


> --Tom
>
>
> On 12/8/14, 1:30 PM, Pravin Shelar wrote:
>>
>> On Mon, Dec 8, 2014 at 9:15 AM, Thomas Graf <tgraf@noironetworks.com>
>> wrote:
>>>
>>> On 12/07/14 at 08:47pm, Pravin Shelar wrote:
>>>>
>>>> Since the beginning OVS kernel datapath development is primarily done
>>>> on external OVS repo. Now we have mostly synced upstream and external
>>>> OVS. So we have decided to change this process. New process is as
>>>> follows.
>>>>
>>>> 1. OVS feature development that involves kernel datapath should be
>>>> done on net-next tree datapath.
>>>> 2. Such feature patch series should be posted on netdev and ovs-dev
>>>> mailing list.
>>>> 3. Once review is done for entire series, kernel and OVS userspace
>>>> patches will be merged in respective repo.
>>>> 4. After the merge developer is suppose to send patches for external
>>>> kernel datapath along with old kernel compatibility code. So that we
>>>> can keep external datapath insync.
>>>
>>> +1
>>>
>>> Just to be clear, by respective repo do you mean net-next/net or will
>>> you maintain a net-next branch on git.kernel.org and continue doing
>>> pull requests?
>>
>> OVS patches will directly go to net-next/net tree. I am not planning
>> on maintaining any tree on git.kernel.org.
>> _______________________________________________
>> dev mailing list
>> dev@openvswitch.org
>> http://openvswitch.org/mailman/listinfo/dev
>
>
>
> --
> Thomas F. Herbert
>
