From: "Andrew Grover" <andy.grover@gmail.com>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 17:02:13 -0700
Message-ID: <c0a09e5c0706291702r6370d38fq1a401650324be1ff@mail.gmail.com>
References: <1183138159.17243.16.camel@blaa>
	 <20070629175006.GB3917@falooley.org> <468571C6.3090305@garzik.org>
	 <46857C08.4030303@intel.com>
	 <20070629150350.414553d4.akpm@linux-foundation.org>
	 <4685838D.9080108@garzik.org>
	 <c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Jason Lunz" <lunz@reflexsecurity.com>,
	"Mark McLoughlin" <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:21405 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981AbXF3ACO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 20:02:14 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1383778wah
        for <netdev@vger.kernel.org>; Fri, 29 Jun 2007 17:02:13 -0700 (PDT)
In-Reply-To: <c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/29/07, Andrew Grover <andy.grover@gmail.com> wrote:
> I think making e1000new ICH9-and-newer isn't really the best place to
> split it. The Windows e1000 driver got split on the PCI->PCIe
> transition, something that clearly delineated what nics one driver
> supported, and the other. There's no real technical reason for
> splitting now other than "this was when e1000old collapsed under its
> own weight".
>
> The PCIe adapters are also the first ones to support multiple queues
> IIRC, maybe that would be an another actual technical reason to split
> it there?

I agree with Jeff BTW, the list of devices each one supports should
have zero overlap.

-- Andy
