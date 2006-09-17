From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [d80211] connecting to B-mode AP
Date: Sat, 16 Sep 2006 21:52:51 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F01785470@dhost002-46.dex002.intermedia.net>
References: <200609152004.59652.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:58537 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751004AbWIQEww convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2006 00:52:52 -0400
Content-class: urn:content-classes:message
In-Reply-To: <200609152004.59652.flamingice@sourmilk.net>
To: "Michael Wu" <flamingice@sourmilk.net>,
	"mabbas" <mabbas@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The extended rates element is only needed if there are more than 8 rates
to report - which is normal for G operation, but not necessary. It only
exists because a particularly popular old 11b MAC codebase crashed when
the normal rate element had more than 8 elements, and this hurt
interoperability with early G AP implementations - so the spec was
changed.

Simon

-----Original Message-----
From: Michael Wu [mailto:flamingice@sourmilk.net] 
Sent: Saturday, September 16, 2006 10:05 AM
To: mabbas
Cc: Simon Barber; netdev@vger.kernel.org
Subject: Re: [d80211] connecting to B-mode AP

On Friday 15 September 2006 19:50, mabbas wrote:
> I see your point here, although some one will file some bugs against 
> the driver about showing G while associating with B-mode AP. By the 
> way how can you figure if the AP is B/G other than the rates?
>
IIRC, only 802.11g APs will send the extended rate information element,
though I don't know if forcing 802.11b on the AP will cause it to stop
sending that. 
(but it might still be okay if it doesn't - it's still a 802.11g AP,
with the faster speeds turned off..)

-Michael Wu
