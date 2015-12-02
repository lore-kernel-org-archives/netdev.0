From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: mac80211 2015-11-26
Date: Wed, 02 Dec 2015 15:43:49 -0500 (EST)
Message-ID: <20151202.154349.931361692047925552.davem@davemloft.net>
References: <1448552352.2167.14.camel@sipsolutions.net>
	<1449049610.2449.3.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbbLBUnv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:43:51 -0500
In-Reply-To: <1449049610.2449.3.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 02 Dec 2015 10:46:50 +0100

>> ----------------------------------------------------------------
>> A small set of fixes for 4.4:
>> =A0* remove NL80211_FEATURE_FULL_AP_CLIENT_STATE again, it
>> =A0=A0=A0was broken and needs more work, we'll enable it for 4.5
>> =A0* fix call_rcu() induced use-after-reset/free in mesh
>> =A0=A0=A0(that was suddenly causing issues in certain tests)
>> =A0* always request block-ack window size 64 as we found
>> =A0=A0=A0some APs will otherwise crash (really ...)
>> =A0* fix P2P-Device teardown sequence to avoid restarting
>> =A0=A0=A0with uninitialized data
>=20
> I've got two more fairly important changes - one for regulatory issue=
s
> and one for an uninitialized variable that was leading to fairly
> obscure bugs - do you prefer I wait, or send a new pull request
> covering this one plus the two new fixes?

Please add them and send a new pull request, I'll just skip over your
existing one.

THanks.
