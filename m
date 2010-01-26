From: Dunc <dunc@lemonia.org>
Subject: Re: Network QoS support in applications
Date: Tue, 26 Jan 2010 14:02:07 +0000
Message-ID: <4B5EF5DF.2070005@lemonia.org>
References: <877hr5nkx0.fsf@purkki.valot.fi>	<20100126.041610.226004766.davem@davemloft.net>	<87wrz5m3cd.fsf@purkki.valot.fi>	<20100126.050645.184040277.davem@davemloft.net> <87my01m0zm.fsf@purkki.valot.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Kalle Valo <kalle.valo@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tang.lemonia.org ([88.208.192.38]:56502 "EHLO tang.lemonia.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753982Ab0AZOWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 09:22:34 -0500
In-Reply-To: <87my01m0zm.fsf@purkki.valot.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> And you are perfectly right, as always. My choise of using the word
> "universal" was bad. With word "universal" I meant to use same network
> QoS API with different network technologies: ethernet, wi-fi,
> bluetooth etc.
> 
> But we don't need to solve everything in one go, instead we can make
> small steps. The first step is to start pushing applications to
> classify their streams. That's the enabler to get some sort of QoS
> support, at least to inside kernel and to the next hop. With luck, in
> future it might get more widely used.
> 
> I was hoping to base the classification on some standard, but there
> doesn't really seem to be one which would specify a complete solution.
> But that's ok, we can always create a de facto standard :)
> 
> I'm curious how other operation systems handle this? Or is it a
> similar situation, nobody just doesn't use QoS for anything?
> 

If applications set the QoS values, the who's to stop someone (for
example) writing a bittorrent client that marks all packets for the
highest priority as if they were VoIP or something? At this point all
the good work done in the applications is useless and the network admin
is going to have to not trust the QoS values and then attempt to
classify traffic by themselves, so it was all a waste of time.

It's probably better to just always leave it up to the network devices IMHO.

Cheers,

Dunc
