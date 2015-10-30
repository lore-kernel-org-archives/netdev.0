From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 3/5] dp83640: Prune rx timestamp list before
 reading from it
Date: Fri, 30 Oct 2015 21:38:12 +0100
Message-ID: <20151030203812.GD27879@netboy>
References: <1446207244-2206-1-git-send-email-stefan.sorensen@spectralink.com>
 <1446207244-2206-4-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35402 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932598AbbJ3UiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 16:38:16 -0400
Received: by wmll128 with SMTP id l128so21010142wml.0
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 13:38:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1446207244-2206-4-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2015 at 01:14:02PM +0100, Stefan S=F8rensen wrote:
> The list of rx timestamps are currently only pruned of old entries wh=
en a
> new entry is inserted. If no new entries are added, old timestamps ma=
y
> survive beyond their lifetime, possible causing them to be attached t=
o
> packets with the same sequence number after a rollover.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
