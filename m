From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next V4 00/13] Add basic VLAN support to bridges
Date: Wed, 19 Dec 2012 17:58:01 -0500
Message-ID: <50D24679.8050507@redhat.com>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com> <CAKTPYJTAB-oOW5UE9EbNxwA+XbhmJu1FLrvq_mU8B1Qi6trxeA@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com,
	erdnetdev@gmail.com, jiri@resnulli.us
To: Andrew Collins <bsderandrew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19924 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004Ab2LSW6I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 17:58:08 -0500
In-Reply-To: <CAKTPYJTAB-oOW5UE9EbNxwA+XbhmJu1FLrvq_mU8B1Qi6trxeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2012 05:54 PM, Andrew Collins wrote:
> On Wed, Dec 19, 2012 at 10:48 AM, Vlad Yasevich <vyasevic@redhat.com> wrote:
>> This series of patches provides an ability to add VLANs to the bridge
>> ports.  This is similar to what can be found in most switches.  The bridge
>> port may have any number of VLANs added to it including vlan 0 priority tagged
>> traffic.  When vlans are added to the port, only traffic tagged with particular
>> vlan will forwarded over this port.  Additionally, vlan ids are added to FDB
>> entries and become part of the lookup.  This way we correctly identify the FDB
>> entry.
>
> This is likely well beyond the scope of this change, but I figured I'd
> throw out the question anyway.  This changeset looks to bring the
> Linux bridging code closer to the 802.1Q-2005 definition of a bridge,
> which is nice to see, I'm curious if this changeset also opens up the
> possibility of supporting MSTP in the future?  The big thing I see
> missing is per-VLAN port state, although I'm not very familiar with
> the current STP/bridge interactions.  Has anyone put any thought into
> what other necessary bridge pieces might be missing for MSTP support?
> (specifically regarding bridge/vlan interaction, obviously something
> to handle the MSTP protocol itself would need to exist as well)
>

heh..  opening up all sorts of cans of worms today... :)

Have only given it some very passing thoughts.  Absolutely nothing 
concrete here.  Maybe someone else has.

-vlad
