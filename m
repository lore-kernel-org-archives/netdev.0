From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: pmtu discovery on SA
Date: Thu, 19 Jul 2007 17:51:56 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD13230268@exch.facton.local>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local> <469B7B99.6040402@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local> <469B878C.1020204@trash.net> <469B8C47.3030306@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230242@exch.facton.local> <469BB50C.10203@trash.net> <469CE9E5.7040003@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323024F@exch.facton.local> <469D3885.7070208@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230254@exch.facton.local> <469E1242.3050105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230257@exch.facton.local> <469E3F6F.6040004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:39036 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765098AbXGSPwF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 11:52:05 -0400
Content-class: urn:content-classes:message
In-reply-to: <469E3F6F.6040004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Just to make it clear: Is this message an error, or a 
> warning or just
> > for information?
> > Could you explain a bit please.
> 
> 
> Its a debugging message nowadays (NETDEBUG). I was mostly interested
> in this since I changed the IPsec MTU calculation in 2.6.22 and it
> might have been a bug.
> 
> > I have no connections hangs or other kind of problems.
> 
> 
> Thanks for clarifying this. I guess the reason why you're seeing
> them now and not before is that we're now always using the maximum
> room available, while previously packets were usually a bit smaller
> than possible.

Yes, our tunnels gained 2 bytes in 2.6.22. Maybe I would have seen the
messages earlier with older kernels too, but our ADSL line started with
2.6.22.

I tested a little bit around and found the ESP pmtud is doing it's job
well.
The message really just says what it does.

Thank you for clarifying this and most notably for fixing the crash bug
so fast!

Daniel
