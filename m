From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Tue, 03 Jun 2008 19:58:42 +0200
Message-ID: <48458652.7020309@trash.net>
References: <20080603080812.GA4514@ff.dom.local> <Pine.LNX.4.64.0806031220490.3438@bizon.gios.gov.pl> <20080603113343.GA4714@ff.dom.local> <48453C70.1040303@trash.net> <Pine.LNX.4.64.0806031449540.3438@bizon.gios.gov.pl> <484542B5.4070401@trash.net> <Pine.LNX.4.64.0806031617310.3438@bizon.gios.gov.pl> <20080603174941.GA2727@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47189 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367AbYFCR6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 13:58:44 -0400
In-Reply-To: <20080603174941.GA2727@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Tue, Jun 03, 2008 at 05:15:04PM +0200, Krzysztof Oledzki wrote:
>>
>> On Tue, 3 Jun 2008, Patrick McHardy wrote:
> ...
>>> Your patch makes it more predictable, so I'm not completely
>>> opposed, but still its just a workaround.
>> Indeed - it is a workaround but I believe we need it.
>>
> 
> IMHO, adding a safety with e.g. CONFIG_IP_FIB_COMPAT_DEPRECATED
> (default N) for one stable, letting to change this back in some
> (probably nonexistent) strange cases, should be enough to keep up
> appearances...


Mhh .. I don't think this is a good solution. Things can
only break if you actually use the new feature, and if
you do, you should simply make sure that all software
running can deal with it. Fixing the routing daemons
should be a triviality.
