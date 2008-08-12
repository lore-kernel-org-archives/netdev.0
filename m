From: Andi Kleen <andi@firstfloor.org>
Subject: Re: tbench regression on each kernel release from 2.6.22 -> 2.6.28
Date: Tue, 12 Aug 2008 09:11:08 +0200
Message-ID: <87r68u1zeb.fsf@basil.nowhere.org>
References: <48A086B6.2000901@linux-foundation.org>
	<20080811.141501.01468546.davem@davemloft.net>
	<48A0B037.501@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:43906 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbYHLHLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 03:11:11 -0400
In-Reply-To: <48A0B037.501@linux-foundation.org> (Christoph Lameter's message of "Mon, 11 Aug 2008 16:33:43 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter <cl@linux-foundation.org> writes:

> Maybe what we are seeing is general bloat in kernel execution paths
> due to the growth in complexity?

Wouldn't surprise me. Have you considered doing profiles? 

e.g. just oprofiling the benchmark on the different kernels and see
if there's some obvious difference in the CPU consumers? 

-Andi
