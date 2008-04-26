From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH][CAN]: Fix copy_from_user() results interpretation
Date: Sat, 26 Apr 2008 12:05:45 +0200
Message-ID: <20080426100545.GB22836@uranus.ravnborg.org>
References: <4812E73A.6060104@hartkopp.net> <20080426.021001.18044508.davem@davemloft.net> <20080426095923.GA22836@uranus.ravnborg.org> <20080426.030146.227030606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oliver@hartkopp.net, wg@grandegger.com,
	urs.thuermann@volkswagen.de, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de, oliver.hartkopp@volkswagen.de,
	xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:41518 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633AbYDZKFO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Apr 2008 06:05:14 -0400
Content-Disposition: inline
In-Reply-To: <20080426.030146.227030606.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 26, 2008 at 03:01:46AM -0700, David Miller wrote:
> From: Sam Ravnborg <sam@ravnborg.org>
> Date: Sat, 26 Apr 2008 11:59:23 +0200
> 
> > diff --git a/scripts/Makefile.build b/scripts/Makefile.build
> > index 277cfe0..4a7327b 100644
> > --- a/scripts/Makefile.build
> > +++ b/scripts/Makefile.build
> > @@ -105,7 +105,7 @@ endif
> >  
> >  # Do section mismatch analysis for each module/built-in.o
> >  ifdef CONFIG_DEBUG_SECTION_MISMATCH
> > -  cmd_secanalysis = ; scripts/mod/modpost $@
> > +  #cmd_secanalysis = ; scripts/mod/modpost $@
> >  endif
> >  
> >  # Compile C sources (.c)
> 
> What's this? :-)

Sorry!
Workaround for a newly introduced kbuild bug and I did
not review my patch properly.
I hand edited it out in first mail but should have
done so in my queued patch to prevent this.

	Sam
