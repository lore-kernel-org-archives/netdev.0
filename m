From: Sam Ravnborg <sam@ravnborg.org>
Subject: PowerPC toolchain for x86 [Was: pci_device_id cleanups]
Date: Wed, 20 Feb 2008 14:55:33 +0100
Message-ID: <20080220135533.GA19024@uranus.ravnborg.org>
References: <1203512031-14318-1-git-send-email-jonas@southpole.se> <20080220131704.GB18790@uranus.ravnborg.org> <47BC2AB7.4040402@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	greg@kroah.com, Andrew Morton <akpm@linux-foundation.org>
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:42301 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763230AbYBTNzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 08:55:23 -0500
Content-Disposition: inline
In-Reply-To: <47BC2AB7.4040402@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 20, 2008 at 02:27:19PM +0100, Jonas Bonn wrote:
> Sam Ravnborg wrote:
> >On Wed, Feb 20, 2008 at 01:53:36PM +0100, Jonas Bonn wrote:
> >>The PCI_DEVICE_TABLE patch I sent earlier doesn't necessarily make
> >>much sense by itself... here is a set of patches that apply
> >>this macro, in turn moving a lot of this data into __devinitconst
> >>which is discardable in certain situations.
> >>Hopefully the benefit of this approach is a bit clearer now.
> >[shorter lines please..]
> 
> Sorry...
> 
> >
> >Can you please confirm that this does not break powerpc (64 bit)
> >as they have troubles with the constification..
> 
> I do not have access to any PowerPC machine... Olof Johansson built the 
> tree I posted earlier on PowerPC; there's nothing really new here except 
> the wrapping of the definition in a macro.
And you added const and a specific section.
Exactly what could break on PowerPC.

To do the build break check is easy.
Google for "crosstool" and build your own powerpc toolchain.

Andrew has something precompiled somewhere but I lost the link.


	Sam
