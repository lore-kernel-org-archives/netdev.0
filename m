From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [clarification request] ieee80211_tx_control.pkt_type
Date: Fri, 18 Aug 2006 09:25:22 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F0165B19D@dhost002-46.dex002.intermedia.net>
References: <1155912648.5671.3.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Jiri Benc" <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:56863 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1030220AbWHRQZW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 12:25:22 -0400
Content-class: urn:content-classes:message
in-reply-to: <1155912648.5671.3.camel@ux156>
To: "Johannes Berg" <johannes@sipsolutions.net>,
	"Jouni Malinen" <jkm@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It might be appropriate to change it from pkt_type to a flag indicating
that a timestamp should be added at TX time "add_timestamp". This may
well also end up being used for beacons too on hardware where the
beacons are completely software generated.

Simon 

-----Original Message-----
From: Johannes Berg [mailto:johannes@sipsolutions.net] 
Sent: Friday, August 18, 2006 7:51 AM
To: Jouni Malinen
Cc: netdev@vger.kernel.org; Simon Barber; Jiri Benc
Subject: Re: [clarification request] ieee80211_tx_control.pkt_type

On Fri, 2006-08-18 at 07:33 -0700, Jouni Malinen wrote:

> Some hardware designs require this configuration for TX frames. It is 
> used to select whether some of the fields are being filled in hardware

> (e.g., timestamp for Probe Response).

Ah ok, timestamp makes sense.

> This would only be needed for AP
> mode and IBSS (adhoc), so it is possible that not all low-level 
> dirvers have yet been implemented to support such operation.

Right.

> This pkt_type was added at generic 802.11 layer in order to avoid 
> forcing the low-level driver to even look at the 802.11 header when 
> queuing the frame for transmission. Taken into account how simple 
> operation it is to get the type and subtype from the frame control 
> field, this tx ctrl pkt_type could be removed, if desired. However, it

> was added there for a reason.

No, that's ok, I was just wondering why it is there at all.

Thanks for clarifying,
johannes
