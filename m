From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 097/101] revert "drivers/net/tulip/dmfe: support basic
 carrier detection"
Date: Wed, 7 Mar 2007 10:14:44 -0800
Message-ID: <20070307101444.52cb2146@freekitty>
References: <20070307171035.150802805@mini.kroah.org>
	<20070307171657.461008445@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, stable@kernel.org, jeff@garzik.org,
	Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	thomas@archlinux.org, val_henson@linux.intel.com,
	samuel.thibault@ens-lyon.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:47006 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992436AbXCGSUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 13:20:01 -0500
In-Reply-To: <20070307171657.461008445@mini.kroah.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 07 Mar 2007 09:12:12 -0800
Greg KH <gregkh@suse.de> wrote:

> 
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Revert 7628b0a8c01a02966d2228bdf741ddedb128e8f8.  Thomas Bachler
> reports:
> 
>   Commit 7628b0a8c01a02966d2228bdf741ddedb128e8f8 (drivers/net/tulip/dmfe:
>   support basic carrier detection) breaks networking on my Davicom DM9009. 
>   ethtool always reports there is no link.  tcpdump shows incoming packets,
>   but TX is disabled.  Reverting the above patch fixes the problem.
> 

Carrier detection support is important and should be fixed rather than removed.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
