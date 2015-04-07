From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: VxLAN system wedge in 4.0.0-rc5+ from davem net-next?
Date: Tue, 07 Apr 2015 12:14:53 +0200
Message-ID: <1428401693.3914618.250169009.7869259D@webmail.messagingengine.com>
References: <551F2C20.1060908@hp.com> <20150406190743.GA3969@localhost.localdomain>
 <5522E5F5.7050605@hp.com> <55230E02.2060204@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:35088 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750994AbbDGKOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 06:14:55 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id B80E320929
	for <netdev@vger.kernel.org>; Tue,  7 Apr 2015 06:14:50 -0400 (EDT)
In-Reply-To: <55230E02.2060204@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 7, 2015, at 00:51, Rick Jones wrote:
> On 04/06/2015 01:00 PM, Rick Jones wrote:
> > On 04/06/2015 12:07 PM, Marcelo Ricardo Leitner wrote:
> >> That means you could send/receive some packets on it before the hang,
> >> right?
> >
> > On v3.19 I could send and receive lots of packets without a hang.  I
> > could even run netperf through the vxlan tunnel :)
> >
> > Now that I've addressed my build issue I'm in the midst of a bisect, but
> > if someone has faster git-fu I'll not be disappointed if they are able
> > to bisect before me.
> 
> The git bisect has implicated:
> 
> b6a7719aedd7e5c0f2df7641aa47386111682df4 is the first bad commit
> commit b6a7719aedd7e5c0f2df7641aa47386111682df4
> Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date:   Wed Mar 25 17:07:44 2015 +0100

Thanks for the report, I try to reproduce this right now!

Bye,
Hannes
