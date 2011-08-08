From: Phillip Susi <psusi@cfl.rr.com>
Subject: Re: 802.3ad bonding brain damaged?
Date: Mon, 08 Aug 2011 16:06:13 -0400
Message-ID: <4E4041B5.5040908@cfl.rr.com>
References: <4E3EECF6.90409@cfl.rr.com> <1312790234.7020.26.camel@arkology.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.122]:57662 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408Ab1HHUHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 16:07:17 -0400
In-Reply-To: <1312790234.7020.26.camel@arkology.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/8/2011 3:57 AM, David Lamparter wrote:
> No, it isn't. 802.3ad/.1AX explicitly requires that no packet
> re-ordering may ever occur, which can only be guaranteed by enqueueing
> packets for one host on one TX interface. This behaviour is mandated by
> 802.1AX-2008 page 15 which reads:

Outch, that does cause a big problem for store-and-forward switching. 
You basically can't split up packets from a single stream without very 
careful cut-through switching, which we obviously can't do in Linux. 
That seems a rather silly requirement given that higher level protocols 
already deal with packet reordering.  Why not an option to say stuff the 
standard?
