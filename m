From: 'Tejun Heo' <tj@kernel.org>
Subject: Re: [PATCH net-next 5/5] net: sctp: fix incorrect type in gfp
 initializer
Date: Thu, 19 Jun 2014 09:46:56 -0400
Message-ID: <20140619134656.GJ11042@htj.dyndns.org>
References: <1402497297-27100-1-git-send-email-dborkman@redhat.com>
 <1402497297-27100-6-git-send-email-dborkman@redhat.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725AF78@AcuExch.aculab.com>
 <5398712C.3000801@redhat.com>
 <CAADnVQLyNCUU0+onEHbygVE-M3WK59uB=NoKWi1V4Rh+6AZkVA@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725B905@AcuExch.aculab.com>
 <20140618183058.GC11042@htj.dyndns.org>
 <063D6719AE5E284EB5DD2968C1650D6D1725EF63@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Alexei Starovoitov' <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:57059 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754545AbaFSNrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 09:47:00 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725EF63@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 19, 2014 at 08:13:48AM +0000, David Laight wrote:
> Apart from the fact that it is badly optimised.
> 
> If z() were an empty #define rather than an empty inline function
> then you'd end up with the:
> 	if (preload)
> 		z();
> being completely optimised away.

This isn't that hot a path and I don't wanna change it to work around
compiler behavior at this level.  If you care about it, please report
it to the compiler people.

Thanks.

-- 
tejun
