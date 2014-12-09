From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: Re: [ovs-dev] OVS Kernel Datapath development
Date: Tue, 09 Dec 2014 09:59:34 -0500
Message-ID: <54870E56.30305@gmail.com>
References: <CALnjE+rn_Giv+8TM1_E2faBftRkivXMYHcjn-4Eq4Gu15r=CiQ@mail.gmail.com> <20141208171506.GC2835@pox.localdomain> <CALnjE+p6udF7oPBBjZWcT79iGOWAwLW3eWzEMJw+MX7W3WOjLA@mail.gmail.com>
Reply-To: thomasfherbert@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:46372 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266AbaLIO7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 09:59:45 -0500
Received: by mail-qc0-f173.google.com with SMTP id i17so526764qcy.4
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 06:59:44 -0800 (PST)
In-Reply-To: <CALnjE+p6udF7oPBBjZWcT79iGOWAwLW3eWzEMJw+MX7W3WOjLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks.

What is the impact on a developer submitting a patch. Do we now submit 
the linux datapath portion of the patch to both netdev and ovs-dev?

--Tom

On 12/8/14, 1:30 PM, Pravin Shelar wrote:
> On Mon, Dec 8, 2014 at 9:15 AM, Thomas Graf <tgraf@noironetworks.com> wrote:
>> On 12/07/14 at 08:47pm, Pravin Shelar wrote:
>>> Since the beginning OVS kernel datapath development is primarily done
>>> on external OVS repo. Now we have mostly synced upstream and external
>>> OVS. So we have decided to change this process. New process is as
>>> follows.
>>>
>>> 1. OVS feature development that involves kernel datapath should be
>>> done on net-next tree datapath.
>>> 2. Such feature patch series should be posted on netdev and ovs-dev
>>> mailing list.
>>> 3. Once review is done for entire series, kernel and OVS userspace
>>> patches will be merged in respective repo.
>>> 4. After the merge developer is suppose to send patches for external
>>> kernel datapath along with old kernel compatibility code. So that we
>>> can keep external datapath insync.
>> +1
>>
>> Just to be clear, by respective repo do you mean net-next/net or will
>> you maintain a net-next branch on git.kernel.org and continue doing
>> pull requests?
> OVS patches will directly go to net-next/net tree. I am not planning
> on maintaining any tree on git.kernel.org.
> _______________________________________________
> dev mailing list
> dev@openvswitch.org
> http://openvswitch.org/mailman/listinfo/dev


-- 
Thomas F. Herbert
