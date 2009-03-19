From: Jeff Chua <jeff.chua.linux@gmail.com>
Subject: Re: Required sequence to set wireless parameters? (was: 2.6.29-rc8:
	Reported regressions from 2.6.28)
Date: Fri, 20 Mar 2009 00:45:17 +0800
Message-ID: <b6a2187b0903190945l29d64016sa755bbd9581968aa@mail.gmail.com>
References: <1237143683.24621.7.camel@johannes.local>
	 <20090315202603.GA9077@elte.hu>
	 <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
	 <1237317742.31814.28.camel@johannes.local>
	 <b6a2187b0903181958ke11abe7tdcbc4efeb950954d@mail.gmail.com>
	 <b6a2187b0903182149x77e416ecuf73be2970173c601@mail.gmail.com>
	 <1237455534.5100.56.camel@johannes.local>
	 <20090319141311.GA3587@tuxdriver.com>
	 <200903191602.58790.elendil@planet.nl>
	 <20090319152441.GB3587@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Frans Pop <elendil@planet.nl>, johannes@sipsolutions.net,
	mingo@elte.hu, torvalds@linux-foundation.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, bunk@kernel.org,
	akpm@linux-foundation.org, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:35864 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376AbZCSQpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 12:45:20 -0400
In-Reply-To: <20090319152441.GB3587@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2009 at 11:24 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> On Thu, Mar 19, 2009 at 04:02:56PM +0100, Frans Pop wrote:
>> John W. Linville wrote:
>> > On Thu, Mar 19, 2009 at 10:38:54AM +0100, Johannes Berg wrote:
>> >> On Thu, 2009-03-19 at 12:49 +0800, Jeff Chua wrote:
>> >> > # this needs patch to work ...
>> >> > iwconfig wlan0 mode Managed
>> >> > ifconfig wlan0 up
>> >> > iwconfig wlan0 essid xxx
>> >> > iwconfig wlan0 key restricted xxx
>> >> > iwconfig wlan0 ap auto channel auto
>> >>
>> >> If you swap the key and essid lines, it will probably always work.

I just discovered that  "iwconfig wlan0 ap auto channel auto" is the
one causing the problem on 2.6.29-rc8. Remove the line and it'll
associate to the AP. Just tried on two different APs a few times, and
it seems to behave that way. If I execute the "auto" command, it'll
fail to associate, but works fine with the patch.

Jeff.
