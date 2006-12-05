From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Madwifi-devel] ar5k and Atheros AR5005G
Date: Tue, 5 Dec 2006 09:18:20 -0800
Message-ID: <20061205091820.2480f92e@freekitty>
References: <1164746352.31456.22.camel@systems03.lan.brontes3d.com>
	<200611291612.33448.mb@bu3sch.de>
	<20061129152407.GB5412@devicescape.com>
	<200611291638.56759.mb@bu3sch.de>
	<20061129160328.GA22602@devicescape.com>
	<20061129121312.4cfc254f@freekitty>
	<43e72e890612011035hf24aeb6wd20f8e93d2238c68@mail.gmail.com>
	<3459.194.45.26.221.1165329546.squirrel@webmail.otaku42.de>
	<43e72e890612050715g9568cfv945f28ccbf796801@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Michael Renzmann" <madwifi@nospam.otaku42.de>,
	"David Kimdon" <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, madwifi-devel@lists.sourceforge.net,
	"Nick Kossifidis" <mickflemm@gmail.com>,
	"Michael Buesch" <mb@bu3sch.de>, "Reyk Floeter" <reyk@openbsd.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:52578 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968482AbWLERUR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 12:20:17 -0500
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890612050715g9568cfv945f28ccbf796801@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 5 Dec 2006 10:15:33 -0500
"Luis R. Rodriguez" <mcgrof@gmail.com> wrote:

> On 12/5/06, Michael Renzmann <madwifi@nospam.otaku42.de> wrote:
>  openhal here.
> >
> > I've set up the suggested branches, with slight changing to the proposed
> > names:
> >
> > * http://svn.madwifi.org/branches/madwifi-old-openhal (based on r1142)
> > * http://svn.madwifi.org/branches/dadwifi-openhal (based on r1827)
> >
> > Neither of them has received any modifications yet, they are basically
> > copies of the mentioned revisions. I'm currently lacking the time to
> > import Nick's work into the madwifi-old-openhal branch, for example - it
> > would be nice if someone else could work on that.
> 
> CC'ing Reyk Foeter.
> 
> Committed Nick's port of ar5k (openal) to both branches, both now have
> the openhal. Please note (very important):
> 
> We are basing our openhal on OpenBSD's ar5k. Because of this and since
> the GPL does not allow us to commit changes on the GPL version back to
> the BSD version please sumbit your non-linux enhancements to the HAL
> to "Reyk Floeter" <reyk@openbsd.org> and CC madwifi-devel.
> 
> We have an openhal.org which we can start to use, should Reyk want, to
> use as the master tree of the ar5k to make sure any enhancements on
> the HAL go to both BSD and Linux. The licensing on the master tree
> should be kept BSD as Reyk wants it to be. This way Linux or BSD
> contributions can go into one tree and later revisions can be added to
> dadwifi/openbsd with their own specific BSD'isms and Linux'isms. Keep
> in mind the Linux port will remain dual licensed BSD/GPL. Let me know
> what you think Reyk.
> 
>   Luis

All the more reason to merge the HAL in and make it disappear

-- 
Stephen Hemminger <shemminger@osdl.org>
