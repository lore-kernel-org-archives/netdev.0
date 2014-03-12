From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH net-next 1/5] vxlan: Make VXLAN default UDP port number
 available for others
Date: Wed, 12 Mar 2014 10:20:14 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A46F7A575@avmb2.qlogic.org>
References: <1394470142-13992-1-git-send-email-shahed.shaikh@qlogic.com>
 <1394470142-13992-2-git-send-email-shahed.shaikh@qlogic.com>
 <CAJZOPZ+MFe2ev372L07uVvXs_wYnqAiZ3VMG4YteD2XmPWHoSQ@mail.gmail.com>
 <262CB373A6D1F14F9B81E82F74F77D5A46F797EE@avmb2.qlogic.org>
 <CAJZOPZKBdZPuEe5uKLb3sw92q3Qko4RS-90uVAQK=+pFXVAfSA@mail.gmail.com>
 <alpine.LFD.2.03.1403111013570.16490@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Dept-HSG Linux NIC Dev" <Dept-HSGLinuxNICDev@qlogic.com>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:18117 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752811AbaCLKUT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 06:20:19 -0400
In-Reply-To: <alpine.LFD.2.03.1403111013570.16490@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joseph Gasparakis [mailto:joseph.gasparakis@intel.com]
> Sent: Tuesday, March 11, 2014 10:59 PM
> To: Or Gerlitz
> Cc: Shahed Shaikh; Joseph Gasparakis; John Fastabend; David Miller; netdev;
> Dept-HSG Linux NIC Dev
> Subject: Re: [PATCH net-next 1/5] vxlan: Make VXLAN default UDP port
> number available for others
> 
> 
> 
...
> 
> For the sake of simplicity: if you have say two VXLANs listening on two
> different UDP ports, and a single port NIC that can only offload traffic from
> one UDP port, how would you know which VXLAN is more useful to offload?
> There might be traffic from the one port (and in this case it might be the
> default one or not) or you might have traffic from both.
> The fact is that you have a hw limitation, and you need something to help
> you predict what which VXLAN you are going to have traffic from which is not
> trivial at all.
> Therefore even having a way to use the routing tables wouldn't help I think.
> 
> In other words, IMHO the best option for running a NIC that can offload X
> UDP ports, is to use up to X UDP ports. Anything else, requres guessing that
> might not be accurate and hence can make things worse instead of better.

Makes sense. Thanks for your feedback Joseph.

Thanks,
Shahed
> 
> >
> > > Like Stephen suggested, exporting udp port variable of vxlan driver will
> be more suitable approach.
> >
