From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: SRIOV as bridge Re: [PATCH net-next RESEND] net: Do not call
 ndo_dflt_fdb_dump if ndo_fdb_dump is defined.
Date: Sun, 21 Dec 2014 14:19:11 -0500
Message-ID: <54971D2F.1090802@mojatatu.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com> <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com> <54902E5E.2070405@mojatatu.com> <54905F67.2090509@gmail.com> <5496D8E2.1090700@mojatatu.com> <54971A93.6050700@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:51064 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbaLUTTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 14:19:14 -0500
Received: by mail-ie0-f175.google.com with SMTP id x19so3232752ier.6
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2014 11:19:14 -0800 (PST)
In-Reply-To: <54971A93.6050700@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/14 14:08, Roopa Prabhu wrote:
> PF still stays but not as the management interface.
>
> Even if 'TheClassThingy' where there, you wouldn't refer to it as the
> master (ie the PF will not have a netdev master/slave relationship with
> the VF). 'master' will still be used for the netdev 'upper'  device if
> VF was enslaved to one (which could be a bridge).
>

Well, there is an embedded switch underneath the VFs (in hardware).
You cant send pkts from one VF to another without going through this
switch (or in VEPA mode via it). i.e you dont need a kernel bridge.
So in essence the VF is a bridge port to  this embedded switch (as
is the PF). So the role of master points downwards from the kernel.
Master is just not visible at the kernel. I am not sure what "self"
would mean in this case.
This is why i dont think current switchdev approach would work.

cheers,
jamal
