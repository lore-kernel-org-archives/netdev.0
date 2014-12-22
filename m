From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: SRIOV as bridge Re: [PATCH net-next RESEND] net: Do not call
 ndo_dflt_fdb_dump if ndo_fdb_dump is defined.
Date: Mon, 22 Dec 2014 08:04:47 -0500
Message-ID: <549816EF.9070402@mojatatu.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com> <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com> <54902E5E.2070405@mojatatu.com> <54905F67.2090509@gmail.com> <5496D8E2.1090700@mojatatu.com> <54971A93.6050700@cumulusnetworks.com> <54971D2F.1090802@mojatatu.com> <54972140.30704@cumulusnetworks.com> <54972859.7050108@mojatatu.com> <549731A1.3090307@cumulusnetworks.com> <54978C3C.4
 040102@mojatatu.com> <5497B916.1020605@cumulusnetworks.com> <54980A33.6000801@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:33586 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978AbaLVNEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 08:04:51 -0500
Received: by mail-ie0-f175.google.com with SMTP id x19so4120525ier.6
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 05:04:50 -0800 (PST)
In-Reply-To: <54980A33.6000801@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/14 07:10, Jamal Hadi Salim wrote:

> Actually you cant list them as netdevs (please someone
> correct me if i am wrong). What you see are PCI devices.

I have been corrected.
It turns out i was wrong. The VFs infact show up as ethx devices.
So your idea of having the devices with "bridge .. self" would work
except when the device moves to a VM and you cant see them anymore...
and you want to add an fdb entry to the embedded switch..

cheers,
jamal
