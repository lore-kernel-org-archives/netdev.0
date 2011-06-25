From: Jesse Gross <jesse@nicira.com>
Subject: Re: [Pv-drivers] [PATCH] vmxnet3: Enable GRO support.
Date: Fri, 24 Jun 2011 17:25:52 -0700
Message-ID: <BANLkTi=MeFB8xvz22pNcgWU7SHcABsm7tA@mail.gmail.com>
References: <1308947605-4300-1-git-send-email-jesse@nicira.com>
 <03E840D17E263A48A5766AD576E0423A0129262BB5@exch-mbx-111.vmware.com>
 <BANLkTi=OJSnGQ99cG-QaaxxMp1od3KGCKQ@mail.gmail.com> <03E840D17E263A48A5766AD576E0423A0129262C0A@exch-mbx-111.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Scott Goldman <scottjg@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:36043 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab1FYA0N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 20:26:13 -0400
Received: by vxb39 with SMTP id 39so2321747vxb.19
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2011 17:26:12 -0700 (PDT)
In-Reply-To: <03E840D17E263A48A5766AD576E0423A0129262C0A@exch-mbx-111.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 24, 2011 at 4:23 PM, Scott Goldman <scottjg@vmware.com> wro=
te:
>> As an aside, in many cases the hypervisor actually has all of the
>> information that is necessary to keep LRO on but does not provide it
>> to the guest. =C2=A0For example, in the VM-to-VM case the MSS is pro=
vided
>> by the sender as part of the TSO descriptor and if given to the
>> receiver we could generate a GSO frame and avoid the need to do GRO =
in
>> the first place. =C2=A0Do you know if it is possible to do this?
>
> I think that sounds like a pretty good idea, but if I understand corr=
ectly, that change needs to go in the hypervisor, not just the driver. =
The device emulation backend needs to populate that MSS somewhere in th=
e receive descriptor. I will file an internal bug about it, but just to=
 set expectations, ESX 5.0 is about to be released, so realistically at=
 the earliest, this change may not be publically available for another =
year.

I had hoped that maybe the information was already being populated by
the hypervisor but not used by the driver.  However, from what I have
gathered that's not the case.

> P.S. Ronghua, the vmxnet3 mastermind, works at Nicira now. If you see=
 him, tell him I said hi.

Sure, I'll say hi next time I see him.
