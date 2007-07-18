From: Patrick McHardy <kaber@trash.net>
Subject: Re: pmtu discovery on SA
Date: Wed, 18 Jul 2007 18:27:27 +0200
Message-ID: <469E3F6F.6040004@trash.net>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local> <469B7B99.6040402@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local> <469B878C.1020204@trash.net> <469B8C47.3030306@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230242@exch.facton.local> <469BB50C.10203@trash.net> <469CE9E5.7040003@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323024F@exch.facton.local> <469D3885.7070208@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230254@exch.facton.local> <469E1242.3050105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230257@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42599 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761000AbXGRQ17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 12:27:59 -0400
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD13230257@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Beschorner Daniel wrote:
>>Beschorner Daniel wrote:
>>
>>So its using 1492 now? Otherwise it would be expected since the
>>initial MTU calculation would be based on 1500.
> 
> 
> I'm using 1500 again.
> 
> Just to make it clear: Is this message an error, or a warning or just
> for information?
> Could you explain a bit please.


Its a debugging message nowadays (NETDEBUG). I was mostly interested
in this since I changed the IPsec MTU calculation in 2.6.22 and it
might have been a bug.

> I have no connections hangs or other kind of problems.


Thanks for clarifying this. I guess the reason why you're seeing
them now and not before is that we're now always using the maximum
room available, while previously packets were usually a bit smaller
than possible.

