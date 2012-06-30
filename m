From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH] iwlegacy: print how long queue was actually stuck
Date: Sat, 30 Jun 2012 21:11:21 +0200
Message-ID: <1341083481.1911.85.camel@x61.thuisdomein>
References: <1340786187.1911.24.camel@x61.thuisdomein>
	 <1341062406.1911.76.camel@x61.thuisdomein>
	 <CANUX_P3kypkUv+-meABAOGa6GQ9cR5ugySJj+SjvVfCykCQuYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Emmanuel Grumbach <egrumbach@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpb-ews02.kpnxchange.com ([213.75.39.5]:1117 "EHLO
	cpsmtpb-ews02.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754036Ab2F3TL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 15:11:27 -0400
In-Reply-To: <CANUX_P3kypkUv+-meABAOGa6GQ9cR5ugySJj+SjvVfCykCQuYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-06-30 at 21:18 +0300, Emmanuel Grumbach wrote:
> You may want to try this one:
> http://www.spinics.net/lists/stable-commits/msg18110.html

That issue looks similar, though it regards iwlwifi. Thanks anyway.
Perhaps commit d6ee27eb13beab94056e0de52d81220058ca2297 ("iwlwifi: don't
mess up the SCD when removing a key") can be ported to iwlegacy. We'll
see whether I manage to port it and whether it helps.

Note that iwlwifi also seems to print the (default) timeout in its
message and not how long a queue was actually stuck. So perhaps
something like my patch could be ported to iwlwifi too.


Paul Bolle
