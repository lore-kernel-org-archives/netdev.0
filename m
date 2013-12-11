From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't work.
Date: Wed, 11 Dec 2013 16:38:13 +0100
Message-ID: <CAB=NE6V-RSnqbAC-0tfYK=WGJLp1aPC2UpFDurs49h+wXr9UfQ@mail.gmail.com>
References: <1507831110.20131018194349@eikelenboom.it> <792757788.20131023142849@eikelenboom.it>
 <1819533168.20131211161710@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Berg, Johannes" <johannes.berg@intel.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:45365 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436Ab3LKPie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 10:38:34 -0500
In-Reply-To: <1819533168.20131211161710@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 11, 2013 at 4:17 PM, Sander Eikelenboom
<linux@eikelenboom.it> wrote:
> Since i haven't got a response to this yet and after having the troubled machine back:
> The problem is still present in linux 3.13-rc3

Keep in mind regulatory hints for Intel or Atheros cards do nothing
other than help compliance further given that the cards already have
their own regulatory data, the user input / hint is only going to
reduce the card's channels further. That said the fact that you are
not seeing a regulatory domain being set is an issue provided you have
CRDA installed or use CONFIG_CFG80211_INTERNAL_REGDB. Keep in mind
that the latest version of wireless-regdb had a signature issue
reported by users and not sure if that is cleared yet, so that would
also prevent the wireless-regdb being read even if CRDA was present.
To rule that out try putting the db.txt into net/wireless/db.txt and
compile with CONFIG_CFG80211_INTERNAL_REGDB for now.

Then send the dmesg output, no need for all that fluffy intel debug
log as its not useful in this case.

  Luis
