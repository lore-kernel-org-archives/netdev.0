From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [rfc] suspicious indentation in do_tcp_setsockopt
Date: Thu, 05 Sep 2013 09:42:44 +0200
Message-ID: <522835F4.1040205@redhat.com>
References: <20130905042045.GD15824@redhat.com> <20130905.003907.664285605568829856.davem@davemloft.net> <20130905044318.GA22806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44847 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757607Ab3IEHms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 03:42:48 -0400
In-Reply-To: <20130905044318.GA22806@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/2013 06:43 AM, Dave Jones wrote:
> On Thu, Sep 05, 2013 at 12:39:07AM -0400, David Miller wrote:
>   > From: Dave Jones <davej@redhat.com>
>   > Date: Thu, 5 Sep 2013 00:20:45 -0400
>   >
>   > > What's the intent here ?
>   >
>   > This stuff is great, do you have a script that looks for this false
>   > indentation pattern?
>
> Coverity. I'm doing daily builds with it now, in the hope of trying
> to catch things faster, but there's a *ton* of old stuff in there
> like this that needs sorting through, because it seems to have strange
> of notions of what a 'new' bug is.

Right, it seems 'new' is just newly *detected*, not necessarily newly
introduced in recent code.

> 	Dave
