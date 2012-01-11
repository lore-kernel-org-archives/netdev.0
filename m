From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: Iproute2 build broken by current kernel headers
Date: Wed, 11 Jan 2012 22:27:51 +0400
Message-ID: <4F0DD4A7.1080204@parallels.com>
References: <20120110105409.3567bb1b@nehalam.linuxnetplumber.net>	<20120110110749.42c1252a@nehalam.linuxnetplumber.net>	<4F0D2D88.8010705@parallels.com> <20120111102400.178baee6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:33036 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932550Ab2AKS15 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jan 2012 13:27:57 -0500
In-Reply-To: <20120111102400.178baee6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> These patches will have to be redone to work with the revised include
> files. The iproute2 changes are not acceptable as is because they do not support
> older kernels.
> 
> It is critical that the resulting code work on both old and new
> kernels. In other words, when the new ss command is built (using your
> patches and 3.3 headers), it:
>  * SHOULD send new diag requests to kernel and be able to display
>    the new UNIX domain info
>  * MUST still work when run against old 3.2 kernel.
> 
> This means the code should send new request first, and if that generates
> an error fallback (silently) to the old message format.

OK, I will rework the patches in this way.

Thanks,
Pavel
