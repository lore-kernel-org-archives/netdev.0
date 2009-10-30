From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Fri, 30 Oct 2009 15:43:50 +0100
Message-ID: <4AEAFBA6.4080403@gmail.com>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com> <20091021165139.GL877@kvack.org> <m1d445yf2x.fsf@fess.ebiederm.org> <20091029233848.GV3141@kvack.org> <m1vdhxu01v.fsf@fess.ebiederm.org> <20091030143527.GA3141@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48599 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932198AbZJ3Onv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 10:43:51 -0400
In-Reply-To: <20091030143527.GA3141@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise a =E9crit :
> On Thu, Oct 29, 2009 at 06:45:32PM -0700, Eric W. Biederman wrote:
>> I was expecting someone to run into problems with the linear directo=
ry
>> of sysfs someday.
>=20
> Alas, sysfs isn't the only offender.
>=20
> 		-ben

In my tests, the sysfs lookup by name is the big offender, I believe yo=
u should
post your rb_tree patch ASAP ;) Then we can go further



