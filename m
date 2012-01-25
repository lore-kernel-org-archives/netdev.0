From: Marcelo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH 2/2] tcp: bind() optimize port allocation
Date: Wed, 25 Jan 2012 16:36:49 -0200
Message-ID: <4F204BC1.9070407@redhat.com>
References: <1327516492-9045-1-git-send-email-fbl@redhat.com> <1327516492-9045-2-git-send-email-fbl@redhat.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11823 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751581Ab2AYSgx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jan 2012 13:36:53 -0500
In-Reply-To: <1327516492-9045-2-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2012 04:34 PM, Flavio Leitner wrote:
> Port autoselection finds a port and then drop the lock,
> then right after that, gets the hash bucket again and lock it.
>
> Fix it to go direct.
>
> Signed-off-by: Flavio Leitner<fbl@redhat.com>

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
