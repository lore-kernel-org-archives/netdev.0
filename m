From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next repost v2 1/3] net: Simplify ptp class checks
Date: Wed, 2 Jul 2014 19:48:15 +0200
Message-ID: <20140702174815.GA8388@localhost.localdomain>
References: <1404312104-19154-1-git-send-email-stefan.sorensen@spectralink.com>
 <1404312104-19154-2-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:48745 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481AbaGBRsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 13:48:37 -0400
Received: by mail-wg0-f43.google.com with SMTP id b13so1154815wgh.14
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 10:48:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1404312104-19154-2-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 02, 2014 at 04:41:42PM +0200, Stefan S=F8rensen wrote:
> Replace two switch statements enumerating all valid ptp classes with =
an if
> statement matching for not PTP_CLASS_NONE.

Originally, I had the explicit list to guard against the possibility
of a filter returning early without some valid PTP_CLASS. I agree with
this change, but we will have to remember to make sure the filter
always returns NONE when the packet isn't recognized.

Acked-by: Richard Cochran <richardcochran@gmail.com>
