From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at virtual
 address 000000b0
Date: Thu, 18 Oct 2007 13:46:06 +0200
Message-ID: <4717477E.8000003@trash.net>
References: <Pine.LNX.4.64.0710170833071.21430@bizon.gios.gov.pl> <4715B26E.20302@cosmosbay.com> <Pine.LNX.4.64.0710171018470.21430@bizon.gios.gov.pl> <4715E60E.3020401@cosmosbay.com> <Pine.LNX.4.64.0710171250480.21430@bizon.gios.gov.pl> <47161415.1060808@cosmosbay.com> <Pine.LNX.4.64.0710181320170.12701@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35439 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762311AbXJRLqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 07:46:32 -0400
In-Reply-To: <Pine.LNX.4.64.0710181320170.12701@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Oledzki wrote:
>> Hum, you are using IPT_TPROXY thing, which is not in linux-2.6.22.9
> 
> It is only compiled in, not used at the moment.

But at least the previous version (before those patches posted a week
ago) touches the routing code in exactly that function.
