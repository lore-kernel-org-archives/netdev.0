From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [ovs-dev] OVS Kernel Datapath development
Date: Mon, 8 Dec 2014 10:30:36 -0800
Message-ID: <CALnjE+p6udF7oPBBjZWcT79iGOWAwLW3eWzEMJw+MX7W3WOjLA@mail.gmail.com>
References: <CALnjE+rn_Giv+8TM1_E2faBftRkivXMYHcjn-4Eq4Gu15r=CiQ@mail.gmail.com>
	<20141208171506.GC2835@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog038.obsmtp.com ([74.125.150.112]:46903 "HELO
	na6sys009bog038.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750988AbaLHSah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 13:30:37 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so3243509igj.4
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 10:30:36 -0800 (PST)
In-Reply-To: <20141208171506.GC2835@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 8, 2014 at 9:15 AM, Thomas Graf <tgraf@noironetworks.com> wrote:
> On 12/07/14 at 08:47pm, Pravin Shelar wrote:
>> Since the beginning OVS kernel datapath development is primarily done
>> on external OVS repo. Now we have mostly synced upstream and external
>> OVS. So we have decided to change this process. New process is as
>> follows.
>>
>> 1. OVS feature development that involves kernel datapath should be
>> done on net-next tree datapath.
>> 2. Such feature patch series should be posted on netdev and ovs-dev
>> mailing list.
>> 3. Once review is done for entire series, kernel and OVS userspace
>> patches will be merged in respective repo.
>> 4. After the merge developer is suppose to send patches for external
>> kernel datapath along with old kernel compatibility code. So that we
>> can keep external datapath insync.
>
> +1
>
> Just to be clear, by respective repo do you mean net-next/net or will
> you maintain a net-next branch on git.kernel.org and continue doing
> pull requests?

OVS patches will directly go to net-next/net tree. I am not planning
on maintaining any tree on git.kernel.org.
