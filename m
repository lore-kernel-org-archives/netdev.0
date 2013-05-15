From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Single socket with TX_RING and RX_RING
Date: Wed, 15 May 2013 17:04:23 +0200
Message-ID: <5193A3F7.7030501@redhat.com>
References: <loom.20130515T144941-798@post.gmane.org> <51938BAD.5050502@redhat.com> <loom.20130515T152203-727@post.gmane.org> <5193A00E.2020507@redhat.com> <5193A128.8030204@redhat.com> <loom.20130515T165501-421@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Ricardo_Tub=EDo?= <rtpardavila@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53160 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758979Ab3EOPE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 11:04:27 -0400
In-Reply-To: <loom.20130515T165501-421@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2013 04:58 PM, Ricardo Tub=EDo wrote:
> Daniel Borkmann <dborkman <at> redhat.com> writes:
[...]
> I have already tried that and, if I use the same socket_fd twice with
> setsockopt(), I get the EBUSY errno from Kernel. Tomorrow, I will try=
 the
> first solution with both sockets (it seems the easiest way); afterwar=
ds, I
> will try to use the TX_RING socket for TX and for RX at a time.
>
> I will come back with the results.

Well, no need. I already told you that it cannot work due to the status=
 bits.
