From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: SRIOV as bridge Re: [PATCH net-next RESEND] net: Do not call
 ndo_dflt_fdb_dump if ndo_fdb_dump is defined.
Date: Sun, 21 Dec 2014 15:06:49 -0500
Message-ID: <54972859.7050108@mojatatu.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com> <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com> <54902E5E.2070405@mojatatu.com> <54905F67.2090509@gmail.com> <5496D8E2.1090700@mojatatu.com> <54971A93.6050700@cumulusnetworks.com> <54971D2F.1090802@mojatatu.com> <54972140.30704@cumulusnetworks.com>
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
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38213 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbaLUUGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 15:06:52 -0500
Received: by mail-ig0-f169.google.com with SMTP id hl2so4435743igb.0
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2014 12:06:52 -0800 (PST)
In-Reply-To: <54972140.30704@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/14 14:36, Roopa Prabhu wrote:
> On 12/21/14, 11:19 AM, Jamal Hadi Salim wrote:
>> On 12/21/14 14:08, Roopa Prabhu wrote:

> 'self' would just mean the driver owns the PF embedded bridge and the
> kernel bridge driver has no role in this. 'self' will just tell the VF
> driver to deal with the fdb mac entry. And the VF driver can push the
> fdb to the PF  (John can confirm if the intel sriov devices really do it
> this way or some other way).
>

If the VFs are exposed as netdevs and the master (or Parent which i 
think the "P" stands for) they point to
is the PF - then is the PF a bridge abstraction?
And if the path is via is the PF - i think that seems like "master"
not self, no?

cheers,
jamal
