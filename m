From: Alex Romosan <romosan@sycorax.lbl.gov>
Subject: Re: 2.6.20-rc1 sky2 problems (regression?)
Date: Thu, 14 Dec 2006 19:53:45 -0800
Message-ID: <878xh9rf06.fsf@sycorax.lbl.gov>
References: <87mz5qnf5q.fsf@sycorax.lbl.gov>
	<E1Gv2kS-0002QY-00@gondolin.me.apana.org.au>
	<20061214192218.35a7f8e1@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sycorax.lbl.gov ([128.3.5.196]:3686 "EHLO sycorax.lbl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965062AbWLODx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 22:53:56 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061214192218.35a7f8e1@localhost.localdomain> (message from
	Stephen Hemminger on Thu, 14 Dec 2006 19:22:18 -0800)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> I have a fixed up version of the vendor driver, I'll repackage it tomorrow.

as per the include file, i ended up replacing all the CHECKSUM_HW with
CHECkSUM_PARTIAL since the functions in questions had to do with
transmit. seems to be working so far without any lockups. we'll see
how long this lasts.

--alex--

-- 
| I believe the moment is at hand when, by a paranoiac and active |
|  advance of the mind, it will be possible (simultaneously with  |
|  automatism and other passive states) to systematize confusion  |
|  and thus to help to discredit completely the world of reality. |
