From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: tbench regression on each kernel release from 2.6.22 -> 2.6.28
Date: Tue, 12 Aug 2008 13:57:13 -0500
Message-ID: <48A1DD09.8000909@linux-foundation.org>
References: <48A086B6.2000901@linux-foundation.org>	<20080811.141501.01468546.davem@davemloft.net>	<48A0B037.501@linux-foundation.org> <87r68u1zeb.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58685 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751654AbYHLS51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 14:57:27 -0400
In-Reply-To: <87r68u1zeb.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Christoph Lameter <cl@linux-foundation.org> writes:
> 
>> Maybe what we are seeing is general bloat in kernel execution paths
>> due to the growth in complexity?
> 
> Wouldn't surprise me. Have you considered doing profiles? 

If I get the time I will try to do that.

Another way to understand why we are accepting the regressions here may be
that we give more consideration to real time issues and deterministic
performance these days. Hardware speed gains compensate for the additional
bloat? (I ran the old kernels on cutting edge hardware after all).
