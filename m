From: "L F" <lfabio.linux@gmail.com>
Subject: Re: e1000 driver and samba
Date: Sat, 15 Sep 2007 08:27:18 -0400
Message-ID: <780b6f780709150527v50ff71b2sf9e5d17b62afeb86@mail.gmail.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>
	 <46EAC25B.2060404@intel.com>
	 <780b6f780709141140l1fd586c9p2aa8efe6ed803d38@mail.gmail.com>
	 <46EAF644.1040006@intel.com>
	 <780b6f780709141737w4e17f0a8r944555f27f7344dd@mail.gmail.com>
	 <20070915010916.d8bd035d.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Kok, Auke" <auke-jan.h.kok@intel.com>
To: "Bill Fink" <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:22612 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbXIOM1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2007 08:27:18 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1309216wah
        for <netdev@vger.kernel.org>; Sat, 15 Sep 2007 05:27:18 -0700 (PDT)
In-Reply-To: <20070915010916.d8bd035d.billfink@mindspring.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/15/07, Bill Fink <billfink@mindspring.com> wrote:
> Would it be worth a shot to try disabling the receiver hardware
> checksumming (ethtool -K ethX rx off)?
I just did, unfortunately it doesn't seem to change much.
In the various attempts, however, I seem to have improved something,
maybe. As I mentioned, the machine work as both a gateway and a samba
server. It seems that as long as the one samba operation is the only
activity that goes on between a specific client and the samba server,
at least I do not get timeouts. I have to investigate further on file
corruption, but the timeout doesn't occur.
As soon as I try to perform a second samba operation - even on read -
or I generate singificant net traffic, the samba connection times out.
I have to assume that the added load is just enough to overload the
link.
The other curious fact is that occasionally the writing effectively
pauses for 1-2s. It then resumes, with no ill effect. I have to assume
that when the timeouts occur, the same thing happens for a
sufficiently long period of time and the connection drops.
For further reference, in case any of it is relevant, the samba shares
are ext3 filesystems residing on a SATA based RAID5 (md) array. I
include this because at a certain point I started suspecting the
filesystem before the network, but it doesn't make too much sense.

LF
