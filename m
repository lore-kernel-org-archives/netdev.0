From: jamal <hadi@cyberus.ca>
Subject: Re: [DOC]: generic netlink
Date: Tue, 20 Jun 2006 10:50:13 -0400
Message-ID: <1150815013.5270.73.camel@jzny2>
References: <1150724482.5815.48.camel@jzny2>
	 <44972743.3040904@watson.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Per Liden <per.liden@ericsson.com>, Jay Lan <jlan@engr.sgi.com>,
	Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:29858 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751166AbWFTOuR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 10:50:17 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FshYa-0002ts-5V
	for netdev@vger.kernel.org; Tue, 20 Jun 2006 10:50:20 -0400
To: Shailabh Nagar <nagar@watson.ibm.com>
In-Reply-To: <44972743.3040904@watson.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-19-06 at 18:37 -0400, Shailabh Nagar wrote:

> Completing the documentation on generic netlink usage will definitely be
> useful. I'd be happy to help out with this since I've recently gone through
> trying to understand and use genetlink for the taskstats interface. Hopefully
> this will help other users like me who aren't netlink experts to begin with !
> 

Thanks - I really appreciate it. 

> I've sent you a patch to the document that attempts to cover the following
> TODOS (didn't see any point sending it to the whole list since its harder to
> read patches to documentation). Pls use as you see fit.
> 

Ive received it and will respond to you privately.

> > TODO:
> > a) Add a more complete compiling kernel module with events.
> > Have Thomas put his Mashimaro example and point to it.
> (not the Mashimaro example, nor a completly compiled module but snippets
> of pseudo code taken from the user space program used in taskstats development,
> modified to the foobar example you've used)

Thomas had a more complete piece of code which exercised more paths.
The document just has to point to where that code is.

> > b) Describe some details on how user space -> kernel works
> > probably using libnl??
> > c) Describe discovery using the controller..
> 
> I'll provide another patch that will cover d) and e) in the set below, again
> in the context of the foobar example, which might need to be modified a bit.
> 

no problem. go nuts.

> > d) talk about policies etc
> > e) talk about how something coming from user space eventually
> > gets to you.
> > f) Talk about the TLV manipulation stuff from Thomas.
> > g) submit controller patch to iproute2
> 
> One point...does d), f) etc. belong in a separate doc describing usage
> of netlink attributes ? Its useful here too but not directly related to
> genetlink perhaps.
> 

My thought was to provide a one-stop shop; however,
it may be a separate doc or incorporated in this and referenced by it.

> > PS:- I dont have a good place to put this doc and point to, hence the
> > 17K attachment
> >
> 
> http://www.kernel.org/pub/linux/kernel/people/hadi/ ?
> 
> (unless your permissions have been revoked for lack of use ! :-)
> 

I am only allowed to put kernel patches there by the powers that be. So
this wont fit the criteria. It is hard to believe in these
times my ISP charges me $1/M/month every time i exceed my allocated 5M
quota. I have been with this ISP for > 10 years, hence migration gets
harder - and given that many years on the same account, even my .bashrc
approaches 5M ;->

cheers,
jamal



