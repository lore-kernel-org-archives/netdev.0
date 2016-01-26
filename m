From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/8] General RFKill improvements
Date: Tue, 26 Jan 2016 14:08:18 +0100
Message-ID: <1453813698.2759.41.camel@sipsolutions.net>
References: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
	 (sfid-20160119_164404_701975_4C6B6276)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcel@holtmann.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jprvita@endlessm.com,
	linux@endlessm.com
To: =?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:39586 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934009AbcAZNIV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2016 08:08:21 -0500
In-Reply-To: <1453218163-31998-1-git-send-email-jprvita@endlessm.com> (sfid-20160119_164404_701975_4C6B6276)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, 2016-01-19 at 10:42 -0500, Jo=C3=A3o Paulo Rechi Vita wrote:
> This series contains a few general improvements to the RFKill code,
> found while
> I was writing the rfkill-all / airplane mode LED trigger. All were
> points where
> I had to read twice or do some other kind of extra effort to fully
> understand
> it, so I think merging these changes will benefit someone trying to
> understand
> the RFKill subsystem in the future.

I applied some of this. I think we need to keep the "state" sysfs
interface, perhaps you want to document it more clearly. I also didn't
apply the first patch since I'd fixed the suspend/pause issue, please
see if any of your patches remain relevant and resend that.

Thanks,
johannes
