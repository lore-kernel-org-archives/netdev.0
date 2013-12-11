From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't work.
Date: Wed, 11 Dec 2013 18:17:19 +0100
Message-ID: <CAB=NE6UP876LzOi9-51dokRyT8TyftGitRSDz1FptSJZ9uK4PQ@mail.gmail.com>
References: <1507831110.20131018194349@eikelenboom.it> <792757788.20131023142849@eikelenboom.it>
 <1819533168.20131211161710@eikelenboom.it> <CAB=NE6V-RSnqbAC-0tfYK=WGJLp1aPC2UpFDurs49h+wXr9UfQ@mail.gmail.com>
 <CAJwzM1nwFa7z5gwh42aj39M2dxVXnuecDrhQkVyL+DDFAXwwbg@mail.gmail.com> <12930742.20131211180047@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Avinash Patil <avinashapatil@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:61553 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab3LKRRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 12:17:40 -0500
In-Reply-To: <12930742.20131211180047@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 11, 2013 at 6:00 PM, Sander Eikelenboom
<linux@eikelenboom.it> wrote:
> Could you send me the patch (or a link to it), i can't find it on the linux-wireless list.

I looked for such a patch and didn't find it either, perhaps both of
your issues are the same as with CRDA and the wireless-regdb not
having a proper signature set. You can verify if this is the case by
just downloading the git repo for wireless-regdb and CRDA and on both
just do:

make
sudo make install

After doing this on wireless-regdb just get the $USER.key.pub.pem and
stash that into the crda/pubkeys/ before compiling. That will let CRDA
trust your own key.

  Luis
