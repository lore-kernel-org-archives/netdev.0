From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] ip: justification for local port range robustness
Date: Thu, 18 Oct 2007 08:30:30 -0700
Message-ID: <20071018083030.05a2aade@freepuppy.rosehill>
References: <m3odewh50m.fsf@bandura.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Anton Arapov <aarapov@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38319 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762434AbXJRPb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 11:31:29 -0400
In-Reply-To: <m3odewh50m.fsf@bandura.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Oct 2007 16:27:37 +0200
Anton Arapov <aarapov@redhat.com> wrote:

> Hi!
> 
>   There is a justifying patch for Stephen's patches. Stephen's patches
> disallows using a port range of one single port and brakes the meaning
> of the 'remaining' variable, in some places it has different meaning.
> My patch gives back the sense of 'remaining' variable. It should mean how
> many ports are remaining and nothing else. Also my patch allows using
> a single port.
> 
>   I sure we must be able to use mentioned port range, this does not
> restricted by documentation and does not brake current behavior.
> 
> usefull links:
> Patches posted by Stephen Hemminger
>   http://marc.info/?l=linux-netdev&m=119206106218187&w=2
>   http://marc.info/?l=linux-netdev&m=119206109918235&w=2
> 
> Andrew Morton's comment
>   http://marc.info/?l=linux-kernel&m=119248225007737&w=2
> 
> == Patch:
> 
> Justification of the Stephen Hemminger's patches, commit numbers
>   06393009000779b00a558fd2f280882cc7dc2008
>   227b60f5102cda4e4ab792b526a59c8cb20cd9f8
> 
>   1. Allows using a port range of one single port.
>   2. Gives back sense of 'remaining' variable.
> 
> Signed-off-by: Anton Arapov <aarapov@redhat.com>

Acked-by: Stephen Hemminger <shemminger@linux-foundation.org>
