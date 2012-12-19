From: Andrew Collins <bsderandrew@gmail.com>
Subject: Re: [PATCH net-next V4 00/13] Add basic VLAN support to bridges
Date: Wed, 19 Dec 2012 15:54:27 -0700
Message-ID: <CAKTPYJTAB-oOW5UE9EbNxwA+XbhmJu1FLrvq_mU8B1Qi6trxeA@mail.gmail.com>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com,
	erdnetdev@gmail.com, jiri@resnulli.us
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:60573 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab2LSXBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 18:01:39 -0500
Received: by mail-pa0-f47.google.com with SMTP id fa10so1631694pad.34
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 15:01:37 -0800 (PST)
In-Reply-To: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 19, 2012 at 10:48 AM, Vlad Yasevich <vyasevic@redhat.com> wrote:
> This series of patches provides an ability to add VLANs to the bridge
> ports.  This is similar to what can be found in most switches.  The bridge
> port may have any number of VLANs added to it including vlan 0 priority tagged
> traffic.  When vlans are added to the port, only traffic tagged with particular
> vlan will forwarded over this port.  Additionally, vlan ids are added to FDB
> entries and become part of the lookup.  This way we correctly identify the FDB
> entry.

This is likely well beyond the scope of this change, but I figured I'd
throw out the question anyway.  This changeset looks to bring the
Linux bridging code closer to the 802.1Q-2005 definition of a bridge,
which is nice to see, I'm curious if this changeset also opens up the
possibility of supporting MSTP in the future?  The big thing I see
missing is per-VLAN port state, although I'm not very familiar with
the current STP/bridge interactions.  Has anyone put any thought into
what other necessary bridge pieces might be missing for MSTP support?
(specifically regarding bridge/vlan interaction, obviously something
to handle the MSTP protocol itself would need to exist as well)
