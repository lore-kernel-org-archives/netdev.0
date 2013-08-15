From: Fernando Gont <fernando@gont.com.ar>
Subject: Re: Fwd: RFC 6980 on Security Implications of IPv6 Fragmentation
 with IPv6 Neighbor Discovery
Date: Thu, 15 Aug 2013 03:28:41 -0300
Message-ID: <520C7519.1010000@gont.com.ar>
References: <20130813221321.AEA1AB1E003@rfc-editor.org> <520B3D81.9070506@gont.com.ar> <20130814230617.GA13066@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([93.186.182.34]:40981 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442Ab3HOG3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 02:29:13 -0400
In-Reply-To: <20130814230617.GA13066@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Hannes,

Thanks so much for your timely response! -- Please find my comments
in-line...

On 08/14/2013 08:06 PM, Hannes Frederic Sowa wrote:
> On Wed, Aug 14, 2013 at 05:19:13AM -0300, Fernando Gont wrote:
>> Folks,
>>
>> FYI. -- this is an important piece when it comes to First Hop (i.e.,
>> "local link") Security.
> 
> Thanks for the heads-up, Fernando!
> 
> I sketched up a patch to protect the receiving side. I still don't know if I
> should make this behaviour default or configurable via a sysctl knob. I really
> don't want to break existing installations.

Make it the default behavior. If anything, provide a sysctl knob to
override it.

Note: In the specific case of NS/NA messages, it's impossible nowadays
to find them fragmented in a real network (we don't even have options
(other than padding) to make NS/NAs grow so large!).



> As an extra plus, we now discard packets with nested fragment headers at once.
> Those packets should never have been accepted.

Is that the "goto fail_hdr" part in your patch?

P.S.: What about RS/RA messages?

Cheers,
-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1
