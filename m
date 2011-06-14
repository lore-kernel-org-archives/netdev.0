From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH net-next 1/2] wireless: Remove casts of void *
Date: Tue, 14 Jun 2011 15:23:07 +1000
Message-ID: <BANLkTi=i30Rn7gpCDbn9KKJucq8CB=hssA@mail.gmail.com>
References: <cover.1308024069.git.joe@perches.com> <337c22b774ff7f007b90b266b25c9a33ff555c48.1308024069.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Christian Lamparter <chunkeey@googlemail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:59334 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081Ab1FNFX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 01:23:28 -0400
In-Reply-To: <337c22b774ff7f007b90b266b25c9a33ff555c48.1308024069.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe,

On Tue, Jun 14, 2011 at 14:02, Joe Perches <joe@perches.com> wrote:
> Unnecessary casts of void * clutter the code.
>
> These are the remainder casts after several specific
> patches to remove netdev_priv and dev_priv.

You seem to have removed a lot of casts that don't relate to these cleanups.

In particular, some of the casts seem to relate more to documentation
rather than just changing pointer types to make the compiler happy. In
particular, I'm referring to the casts describing the different usages
of data_buf in mwiflex, and around some pointer math in ath9k.

Whilst I'm sure that the compiler is smart enough to handle automatic
casts between pointer types, some of these, in particular the mwiflex
bits, add some documentation to the code.

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
.Plan: http://sites.google.com/site/juliancalaby/
