From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][GENETLINK] move command capabilities  to flags
Date: Mon, 04 Dec 2006 08:01:09 -0500
Message-ID: <1165237269.3664.15.camel@localhost>
References: <1165060612.3564.8.camel@localhost>
	 <20061204092041.GN8693@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.236]:17892 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S936798AbWLDNBQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 08:01:16 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1850711nze
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 05:01:13 -0800 (PST)
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061204092041.GN8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-04-12 at 10:20 +0100, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-12-02 06:56
> > 
> > Dave,
> > If there is no objections on this approach, please apply this patch.
> > Against net-2.6.20
> > 
> > cheers,
> > jamal
> 
> > This patch moves command capabilities to command flags. Other than
> > being cleaner, saves several bytes.
> 
> Is it worth to save these 12 bytes by breaking compatibility? 

The savings bytes is one aspect; the other is the cleanliness.
transfering a boolean in that many bits is a little of overkill.
I think it is better to fix it now than later.
I know you mentioned libnl uses it. But that is something you can change
on your side. I dont know of any other app that uses it. 

> If you
> really want to do it, remove the obsoleted attribute types, I don't
> like dead bodies laying around :-)

I could resend the patch getting rid of those definitions. 

cheers,
jamal

