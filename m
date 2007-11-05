From: Christoph Lameter <clameter@sgi.com>
Subject: Re: RFC: Reproducible oops with lockdep on count_matching_names()
Date: Mon, 5 Nov 2007 10:47:31 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0711051046210.13139@schroedinger.engr.sgi.com>
References: <20071101191716.GA3201@pogo> <200711051403.39479.mb@bu3sch.de>
 <84144f020711050556m6675ea90g1b6c8054a3940ec0@mail.gmail.com>
 <200711051526.41273.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Peter Zijlstra <peterz@infradead.org>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ingo Molnar <mingo@redhat.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	linux-kernel@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:58961 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754518AbXKESrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 13:47:33 -0500
In-Reply-To: <200711051526.41273.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Nov 2007, Michael Buesch wrote:

> Hm, I don't really remember. Though, I usually have all almost kernel-hacking
> options enabled.
> I'll check and enable some more.

slub_debug must be specified on the command line. Alternately switch on
CONFIG_SLUB_DEBUG_ON in the .config to force it to be always on.
