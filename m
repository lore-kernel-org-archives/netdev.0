From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: tcp/udp checksum on loopback interface
Date: Mon, 25 Jul 2011 18:04:18 -0600
Message-ID: <4E2E0482.7030008@genband.com>
References: <4E292E51.4040802@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pierre Louis Aublin <pierre-louis.aublin@inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og109.obsmtp.com ([64.18.2.171]:32849 "EHLO
	exprod7og109.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062Ab1GZAE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 20:04:57 -0400
In-Reply-To: <4E292E51.4040802@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2011 02:01 AM, Pierre Louis Aublin wrote:
> Hello everybody
>
> I am interested in the reliability of TCP and UDP using the loopback
> interface.
> I found that there is no checksum verification on the body of packets
> transmitted through the loopback interface :

> Finally, why this behaviour? Is it because you assume message can not
> get corrupted while staying on the same machine?

That's correct.  We can save cpu time by not doing the checksum because 
we assume that our own hardware won't introduce errors (or if it does 
and we care about them we'll be monitoring the hardware for ECC errors 
anyways).

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
