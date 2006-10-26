From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Thu, 26 Oct 2006 14:41:05 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F018B5607@dhost002-46.dex002.intermedia.net>
References: <1161876783.2927.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Johannes Berg" <johannes@sipsolutions.net>,
	"Michael Wu" <flamingice@sourmilk.net>,
	"David Kimdon" <dwhedon@devicescape.com>, <netdev@vger.kernel.org>,
	"Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jean Tourrilhes" <jt@hpl.hp.com>, "Hong Liu" <hong.liu@intel.com>,
	"Jouni Malinen" <jkmaline@cc.hut.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:30387 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1945941AbWJZVkv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 17:40:51 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1161876783.2927.37.camel@localhost.localdomain>
To: "Dan Williams" <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Getting people to use wpa_supplicant almost exclusivly as the interface
for wireless will improve a lot of things. One thing that might help
here is to do some work on the wpa_cli - to make it easier for the
startup scripts to do what they need, and also to make the command
syntax easier for command line users to do what they need.

Simon 

-----Original Message-----
From: Dan Williams [mailto:dcbw@redhat.com] 
Sent: Thursday, October 26, 2006 8:33 AM
To: Luis R. Rodriguez
Cc: Johannes Berg; Michael Wu; Simon Barber; David Kimdon;
netdev@vger.kernel.org; Jiri Benc; John W. Linville; Jean Tourrilhes;
Hong Liu; Jouni Malinen
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211

On Thu, 2006-10-26 at 11:04 -0400, Luis R. Rodriguez wrote:
> On 10/26/06, Dan Williams <dcbw@redhat.com> wrote:
> > While wpa_supplicant is certainly the main client for stuff directly

> > related to setting up a connection, there are quite a few other 
> > users of general WE calls to pull information out of the card, or to

> > receive scan events.
> 
> How about we just ditch iwconfig completely and move on to 
> wpa_supplicant/wpa_cli as our next userspace application with
> nl80211/cg80211 as our new API for usersapce-->kernel communication?
> As you point out, wpa_supplicant already does a lot for us -- and 
> several distributions already rely on it. Some work is required but I 
> think its worth it. If we do a complete move from WE to nl80211 it 
> would be transparent to the users too.

The one blocker I can think of here is startup scripts on various
distributions.  Most of those are shell, and they usually rely on
iwconfig quite heavily.  Getting those converted to wpa_supplicant
wouldn't be a trivial amount of work, but it wouldn't be a ton either.

Dan

