From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] configure: Add search path for 64bit library.
Date: Sun, 9 Sep 2012 21:42:58 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1209092141390.22738@frira.zrqbmnf.qr>
References: <1344313376-22602-1-git-send-email-lw@cn.fujitsu.com> <1344363358.2688.8.camel@bwh-desktop.uk.solarflarecom.com> <20120813082624.153167a8@nehalam.linuxnetplumber.net> <1344874960.2733.2.camel@bwh-desktop.uk.solarflarecom.com>
 <20120813093323.1506aa83@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Li Wei <lw@cn.fujitsu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:48641 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752589Ab2IITnB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Sep 2012 15:43:01 -0400
In-Reply-To: <20120813093323.1506aa83@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2012-08-13 18:33, Stephen Hemminger wrote:
>> > > >  	IPT_LIB_DIR=""
>> > > > -	for dir in /lib /usr/lib /usr/local/lib
>> > > > +	for dir in /lib /usr/lib /usr/local/lib /lib64 /usr/lib64 /usr/local/lib64
>> > > >  	do
>> > > >  		for file in $dir/{xtables,iptables}/lib*t_*so ; do
>> > > >  			if [ -f $file ]; then
>> > > 
>> > > I think this should be done with pkg-config:
>> > > 
>> > >     pkg-config --variable=xtlibdir xtables
>> > 
>> > Does every distro have pkg-config or does more logic need to be done here?
>> 
>> Every distro has pkg-config; the question is whether you want to support
>> library versions that don't include a pkg-config file (xtables.pc), if
>> they exist.
>
>Let's do pkg-config first, and as a fallback keep the old code and only
>look in the same old places.

Every distro that has libxtables.so also has the .pc file.

The obvious reason to have the .pc file is to render such error
prone static path searching redundant.
