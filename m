From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Bug 120441] af_packet no longer uses symmetric hashing
Date: Thu, 16 Jun 2016 16:50:02 +0200
Message-ID: <40238392-1c86-53ce-7722-51dd5c2dc294@stressinduktion.org>
References: <511F6A17-BD35-4846-A717-1463B74D7F2A@gmail.com>
 <5762B9C0.9010902@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com, jiri@resnulli.us,
	willemb@google.com, eric@regit.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	Derek Ditch <derek.ditch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:57366 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754245AbcFPOuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 10:50:07 -0400
In-Reply-To: <5762B9C0.9010902@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.06.2016 16:37, Daniel Borkmann wrote:
> On 06/16/2016 03:57 PM, Derek Ditch wrote:
> [...]
>>> Begin forwarded message:
>>>
>>> From: bugzilla-daemon@bugzilla.kernel.org
>>> Subject: [Bug 120441] af_packet no longer uses symmetric hashing
>>> Date: June 16, 2016 at 07:35:54 -0500
>>> To: derek.ditch@gmail.com
>>>
>>> https://bugzilla.kernel.org/show_bug.cgi?id=120441
> 
> Just thinking out loud, perhaps one way would be to implement your own
> fanout
> hashing via eBPF demuxer, f.e. in case CPU selection etc wouldn't work.
> Another
> option could be to have a (2nd) customizable hash demux that would
> enforce to
> always go through the flow-dissector and where you would have a socket
> option
> to control keys for it, but I presume that seems rather less desirable.

Isn't a symmetric hashing for af-packet something very fundamental?
Looks much more like a bug to me.

Bye,
Hannes
