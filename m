From: Marcelo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH 1/2] tcp: bind() fix autoselection to share ports
Date: Wed, 25 Jan 2012 16:36:34 -0200
Message-ID: <4F204BB2.6010905@redhat.com>
References: <1327516492-9045-1-git-send-email-fbl@redhat.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18717 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036Ab2AYSgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jan 2012 13:36:37 -0500
In-Reply-To: <1327516492-9045-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2012 04:34 PM, Flavio Leitner wrote:
> The current code checks for conflicts when the application
> requests a specific port.  If there is no conflict, then
> the request is granted.
>
> On the other hand, the port autoselection done by the kernel
> fails when all ports are bound even when there is a port
> with no conflict available.
>
> The fix changes port autoselection to check if there is a
> conflict and use it if not.
>
> Signed-off-by: Flavio Leitner<fbl@redhat.com>

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
