From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: Problems with 3c59x driver (extremely low throughput)
Date: Tue, 18 Sep 2007 15:28:17 +0200
Message-ID: <20070918132817.GA16768@newton.mathematik.tu-chemnitz.de>
References: <46EFB730.2070201@zero-kelvin.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mikael Leivisk? <mikael@zero-kelvin.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from john.hrz.tu-chemnitz.de ([134.109.132.2]:41230 "EHLO
	john.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755206AbXIRN2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 09:28:24 -0400
Content-Disposition: inline
In-Reply-To: <46EFB730.2070201@zero-kelvin.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 18, 2007 at 01:32:00PM +0200, Mikael Leivisk? wrote:
> OK first of all I'm not really sure if this is the place but was told by
>  Dave Dillow to send to the netdev kernel mailing list. So that's what
> I'm doing :)
> 
> I tried searching the mailing lists and didn't find anything that seemed
> relevant, it is possible I missed something the archives are huge...
> 
> Following is the mail I sent originally:
> 
> I've run into something of a strange problem lately, I have a network
> card that runs on the Vortex/Boomerang driver. I ran the 2.6.16 kernel
> without any issues, and later switched to 2.6.22 because I couldn't get
> my IPSEC tunnel working with 2.6.16 for some reason (didn't find the
> right switches in menuconfig). And everything was seemingly working fine
> but soon after my ISP got some problems and they said they had to
> replace some hardware somewhere along my route and now when I access the
> internet (the machine is setup as router/web-file-mail-server with this
> card as the external interface) I get dreadfully slow speeds, I'll be
> lucky to get 10KB/s on a 10MB/s link. 

Does this mean that the driver worked well with 2.6.22 befor the hardware
changes of your ISP? What did they change?

> But the funny thing is if I switch
> to the 2.6.16 kernel, WHAM I get 700KB/s no sweat... The kernel
> configurations are otherwise almost exactly the same bar tickless and
> some switches in network options to get ipsec... The only thing I do is
> change the kernel and things work...
> 
> So my questions are,
> Has there been any recent changes to the drivers for the card lately?
> (between .16 and .22)

There were some changes, your problem could be related to one of them. 

> Or any changes in the network infrastructure that could be the cause of it?
> Or is there some other switch in the config that could be the cause of this?
> Or is it my ISP's hardware that's not playing nice?
> Or any other ideas as to what might be the cause.
> 
> I've posted the respective kernel configs, and lspci output and my
> cpuinfo on http://www.zero-kelvin.org/pub/kern/
> 
> If there is any other info that you need I'll gladly provide it assuming
> I can get my hands on it   :)

There were some duplex related fixes on 3c59x recently,
could you please try whether your problem persist in 2.6.23-rc6?

Steffen
