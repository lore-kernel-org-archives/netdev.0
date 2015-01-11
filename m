From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net] packet: bail out of packet_snd() if L2 header
 creation fails
Date: Sun, 11 Jan 2015 10:52:25 -0800
Message-ID: <1421002345.9233.1.camel@perches.com>
References: <1420999276-28225-1-git-send-email-cj@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, willemb@google.com, edumazet@google.com,
	dborkman@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christoph Jaeger <cj@linux.com>, Alan <alan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0127.hostedemail.com ([216.40.44.127]:43981 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751085AbbAKSwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2015 13:52:30 -0500
In-Reply-To: <1420999276-28225-1-git-send-email-cj@linux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-01-11 at 13:01 -0500, Christoph Jaeger wrote:
> Due to a misplaced parenthesis, the expression
> 
>   (unlikely(offset) < 0),
> 
> which expands to
> 
>   (__builtin_expect(!!(offset), 0) < 0),

Here's another one:

drivers/platform/goldfish/goldfish_pipe.c:285:	if (unlikely(bufflen) == 0)
