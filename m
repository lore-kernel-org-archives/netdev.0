From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 13/17] i40e: AQ API updates for new commands
Date: Thu, 15 Jan 2015 20:04:52 +0200
Message-ID: <CAJ3xEMgim-97TRkGKfVRdyE49-PRR-mt11Ckq1uOuJuZbvXZcQ@mail.gmail.com>
References: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1421324368-6860-14-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAJ3xEMiCLBjuUSh1HGhfJU0gqA7J1MHsp0riLU5kk_uwkAdFqg@mail.gmail.com>
	<FC41C24E35F18A40888AACA1A36F3E418ADD335B@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"Krawczyk, Kamil" <kamil.krawczyk@intel.com>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:36755 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbbAOSEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 13:04:53 -0500
Received: by mail-ob0-f170.google.com with SMTP id wp18so14872052obc.1
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 10:04:52 -0800 (PST)
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418ADD335B@fmsmsx115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2015 at 7:19 PM, Nelson, Shannon
<shannon.nelson@intel.com> wrote:
>> From: Or Gerlitz [mailto:gerlitz.or@gmail.com]
>> Sent: Thursday, January 15, 2015 9:14 AM
>>
>> On Thu, Jan 15, 2015 at 2:19 PM, Jeff Kirsher
>> <jeffrey.t.kirsher@intel.com> wrote:
>> > From: Shannon Nelson <shannon.nelson@intel.com>
>> >
>> > Add lldp control commands, add oem ocsd and ocbb commands, and fix up
>> > NVM config read and write data structs.
>>
>> Sounds to me like a proofed nightmare for someone doing future
>> bisection and landing here... we want kernel patches to be made of
>> basically one logical change, right?
>
> Yes, but note that these are mostly API additions for transactions that aren't used in the code quite yet.  There are a couple of defines that get changed as well, but they aren't used yet either else they'd be accompanied by related code changes.


So NVM config read and write data structs aren't in use? anyway, this
way or another, I think we should stick to the practice of avoiding to
load few different changes on one patch
