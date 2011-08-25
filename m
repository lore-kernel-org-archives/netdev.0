From: jamal <hadi@cyberus.ca>
Subject: Re: Traffic shaping - class ID 16bit limit?
Date: Thu, 25 Aug 2011 16:26:53 -0400
Message-ID: <1314304013.2329.3.camel@mojatatu>
References: <CAO0uZ+-fv89Z3-9+vh5kN93xe=Uw8b=PSfnAqosOjUBP6PcVNg@mail.gmail.com>
	 <20110825093937.2a8a1457@nehalam.ftrdhcpuser.net>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Miroslav Kratochvil <exa.exa@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:33726 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089Ab1HYU1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 16:27:01 -0400
Received: by vws1 with SMTP id 1so2333935vws.19
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 13:27:00 -0700 (PDT)
In-Reply-To: <20110825093937.2a8a1457@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-08-25 at 09:39 -0700, Stephen Hemminger wrote:

> Granted it was a poor choice in the initial design.
> It is wired into the API and changing it would be quite painful.
> 

You should be able to have infinite queues if you use the 
hierachies. i.e each hierachy should expose a new 16 bit
namespace. 

cheers,
jamal
