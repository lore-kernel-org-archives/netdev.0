From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [ovs-dev] OVS Kernel Datapath development
Date: Tue, 9 Dec 2014 10:36:14 -0800
Message-ID: <CALnjE+rd5HN1zqHA6CJGhRGW2wsR1aURHoWs94_a=KyvNo4wwQ@mail.gmail.com>
References: <CALnjE+rn_Giv+8TM1_E2faBftRkivXMYHcjn-4Eq4Gu15r=CiQ@mail.gmail.com>
	<5487392A.4020409@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Lori Jakab <lojakab@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog017.obsmtp.com ([74.125.150.74]:43470 "HELO
	na6sys009bog017.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751876AbaLISgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:36:15 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so1105780ieb.3
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 10:36:14 -0800 (PST)
In-Reply-To: <5487392A.4020409@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 9, 2014 at 10:02 AM, Lori Jakab <lojakab@cisco.com> wrote:
> On 12/08/2014 06:47 AM, Pravin Shelar wrote:
>> Since the beginning OVS kernel datapath development is primarily done
>> on external OVS repo. Now we have mostly synced upstream and external
>> OVS. So we have decided to change this process. New process is as
>> follows.
>
> Patch series that have previous revisions already reviewed with the old
> process should now switch to the new process?  Or does the change apply
> only to new patch series?
>

All patch series should follow new process including the one which got
reviewed partially.

> -Lori
>
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
>>
>>
>> Thanks,
>> Pravin.
