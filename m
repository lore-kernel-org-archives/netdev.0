From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Thu, 26 Oct 2006 11:33:03 -0400
Message-ID: <1161876783.2927.37.camel@localhost.localdomain>
References: <20061024140212.GB17543@devicescape.com>
	 <C86180A8C204554D8A3323D8F6B0A29F018523A5@dhost002-46.dex002.intermedia.net>
	 <43e72e890610241503r692975dfx65b2eab987ffbb3d@mail.gmail.com>
	 <200610241853.03135.flamingice@sourmilk.net>
	 <43e72e890610251043y22fb9ce6ne5e036dd58f36505@mail.gmail.com>
	 <1161813628.8884.14.camel@johannes.berg>
	 <1161873333.2927.9.camel@localhost.localdomain>
	 <43e72e890610260804q28505f71v6053f8dbbd457ac7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Michael Wu <flamingice@sourmilk.net>,
	Simon Barber <simon@devicescape.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>, Hong Liu <hong.liu@intel.com>,
	Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:7838 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1423571AbWJZPds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 11:33:48 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890610260804q28505f71v6053f8dbbd457ac7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-10-26 at 11:04 -0400, Luis R. Rodriguez wrote:
> On 10/26/06, Dan Williams <dcbw@redhat.com> wrote:
> > While wpa_supplicant is certainly the main client for stuff directly
> > related to setting up a connection, there are quite a few other users of
> > general WE calls to pull information out of the card, or to receive scan
> > events.
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

