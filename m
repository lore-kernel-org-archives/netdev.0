From: Jesse Gross <jesse@nicira.com>
Subject: Re: ovs datapath complains on unexpected mask for netlink commands
Date: Wed, 3 Dec 2014 09:09:09 -0800
Message-ID: <CAEP_g=_dqDuEaKvSt3CwCXJug6GbHjF4P_HCOX_z1cNQosAORg@mail.gmail.com>
References: <54775D61.6090300@mellanox.com> <CAEP_g=-g7hH2NtOzdzRMiv+1onk74e0Tny8H0v7zHoqqTvog7Q@mail.gmail.com>
 <CAJ3xEMjL-ngoniJP9Lrw-UYMuHfQsEB8+OoR7W1GRQDD8aOnmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Pravin Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog031.obsmtp.com ([74.125.150.105]:35025 "HELO
	na6sys009bog031.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750969AbaLCRJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 12:09:31 -0500
Received: by mail-qc0-f181.google.com with SMTP id m20so11537600qcx.12
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 09:09:30 -0800 (PST)
In-Reply-To: <CAJ3xEMjL-ngoniJP9Lrw-UYMuHfQsEB8+OoR7W1GRQDD8aOnmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 3, 2014 at 9:01 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Tue, Dec 2, 2014 at 1:39 AM, Jesse Gross <jesse@nicira.com> wrote:
>> On Thu, Nov 27, 2014 at 9:20 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>>> Hi Jesse,
>>>
>>> I am running with net-next as of commit 2ad7bf36 "ipvlan: Initial check-in
>>> [...]"
>>> and user-space OVS v2.0.90 built from the upstream git.
>>>
>>> I suddenly realized that my kernel logs gets filled with the below
>>> prints which effectively take place for each ovs-vsctl command I run...
>>>
>>> openvswitch: netlink: Unexpected mask (mask=1205c, allowed=19805c)
>>> openvswitch: netlink: Unexpected mask (mask=1205c, allowed=19805c)
>>> openvswitch: netlink: Unexpected mask (mask=1205c, allowed=19805c)
>>> openvswitch: netlink: Unexpected mask (mask=1205c, allowed=19805c)
>>> openvswitch: netlink: Unexpected mask (mask=1205c, allowed=19805c)
>>
>> Thanks I see the problem. It looks like Pravin just sent out a patch
>> to fix this issue last night - "[PATCH net] openvswitch: Fix flow mask
>> validation.".
>
> I see, now (I know the patch wasn't applied yet) on my net clone, the
> complaint is a bit different...
>
> openvswitch: netlink: Contain more than allowed mask fields
> (mask_attrs=1205c, mask_allowed=19805c).
> openvswitch: netlink: Contain more than allowed mask fields
> (mask_attrs=19a05c, mask_allowed=19805c).
>
> so same fix for that too?

It's the same problem, only the text string was changed in the meantime.
