From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 2/2][INET] Move the reqsk_queue_yank_listen_sk from header
Date: Thu, 15 Nov 2007 11:12:33 +0300
Message-ID: <473BFF71.60501@openvz.org>
References: <473B3A3A.70207@openvz.org> <20071115001226.GJ2368@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:46349 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753004AbXKOING (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 03:13:06 -0500
In-Reply-To: <20071115001226.GJ2368@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Horman wrote:
> On Wed, Nov 14, 2007 at 09:11:06PM +0300, Pavel Emelyanov wrote:
>> This function is used in the net/core/request_sock.c only.
>> No need in keeping it in the header file.
> 
> I feel like I am missing something here, but 
> doesn't __reqsk_queue_destroy() in include/net/request_sock.h use
> reqsk_queue_yank_listen_sk()?

It does, but this is a patch number 2. The patch number 1 moved this
__reqsk_queue_destroy() into request_sock.c.

> static inline void __reqsk_queue_destroy(struct request_sock_queue
> *queue)
> {
>         kfree(reqsk_queue_yank_listen_sk(queue));
> }

Thanks,
Pavel
