From: Kasper Sandberg <lkml@metanurb.dk>
Subject: Re: Realtek 8111c weirdness problems, apic/msi, and normal bug
Date: Sat, 12 Apr 2008 14:23:28 +0200
Message-ID: <1208003008.1514.38.camel@localhost>
References: <1207407804.14885.27.camel@localhost>
	 <20080405232354.57ff2fac.akpm@linux-foundation.org>
	 <20080406140624.GA24479@electric-eye.fr.zoreil.com>
	 <1207541340.30698.18.camel@localhost>  <1207829872.1514.3.camel@localhost>
	 <1207876315.1514.21.camel@localhost>  <1207937216.1514.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML Mailinglist <linux-kernel@vger.kernel.org>,
	linux-acpi@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:53907 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932161AbYDLMZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 08:25:57 -0400
In-Reply-To: <1207937216.1514.30.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've got some more information (though probably not too helpful).
Realtek has modified(i probably mentioned this earlier) the r8169
driver, under the name of r8168. It might be worth checking out what
they have done. people are reporting that it works:
http://damienkane.livejournal.com/5574.html
http://www.mail-archive.com/ubuntu-bugs%
40lists.ubuntu.com/msg730229.html

the driver can be found at:
http://www.realtek.com.tw/downloads/downloadsView.aspx?Langid=1&PNid=13&PFid=5&Level=5&Conn=4&DownTypeID=3&GetDown=false
if that doesent work, do: http://www.realtek.com.tw/downloads ->
communication networks ics -> network interface controllers ->
10/100/1000 gigabit ethernet -> pci express.

I will try myself, but i have zero knowledge about this stuff in the
kernel, and will probably not be able to find anything of use.


On Fri, 2008-04-11 at 20:06 +0200, Kasper Sandberg wrote:
> I've got more information again. This is dmesg, and /proc/interrupts
> from a livecd (systemrescuecd), its a .23.14, and only 1 nic works (the
<snip>
> 
> On Fri, 2008-04-11 at 03:11 +0200, Kasper Sandberg wrote:
> > Sorry for top posting, but its just easier in this case :)
> > 
> <snip>
> > > 
> > > 
> > > > > 
> > > > 
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > > Please read the FAQ at  http://www.tux.org/lkml/
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > Please read the FAQ at  http://www.tux.org/lkml/

