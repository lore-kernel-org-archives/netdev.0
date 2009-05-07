From: Jon Smirl <jonsmirl@gmail.com>
Subject: Re: Help interpreting MII negotiation
Date: Wed, 6 May 2009 23:30:08 -0400
Message-ID: <9e4733910905062030yb63ef3eoa6347123507969ef@mail.gmail.com>
References: <9e4733910905061903x693ca36av38ff4cc9aef4ce38@mail.gmail.com>
	 <1241664912.29051.18.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f125.google.com ([209.85.221.125]:58684 "EHLO
	mail-qy0-f125.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbZEGDaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 23:30:09 -0400
Received: by qyk31 with SMTP id 31so925020qyk.33
        for <netdev@vger.kernel.org>; Wed, 06 May 2009 20:30:09 -0700 (PDT)
In-Reply-To: <1241664912.29051.18.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 6, 2009 at 10:55 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Wed, 2009-05-06 at 22:03 -0400, Jon Smirl wrote:
>> I don't understand why speed selection is getting set at 10Mbps in this example.
>> It looks to me like the devices auto negotiated 100Mbps.
> [...]
>
> The "speed selection" bits have no meaning unless auto-negotiation is
> disabled.

Thanks, that explains the first example.

What is going on in the second example? That PHY is jumpered to 100Mb.
My host is 100/10 capable. Why is it reporting 10Mb when the PHY is only
capable of 100Mb?

>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>



-- 
Jon Smirl
jonsmirl@gmail.com
