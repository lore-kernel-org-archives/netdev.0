From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH next resend] tcp: use zero-window when free_space is low
Date: Thu, 13 Feb 2014 09:18:36 -0800
Message-ID: <52FCFE6C.4060002@hp.com>
References: <1392292350-28800-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:42662 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbaBMRSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 12:18:38 -0500
In-Reply-To: <1392292350-28800-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/13/2014 03:52 AM, Florian Westphal wrote:
>   Maybe someone has better idea?

Does tcp_rmem have to be a "hard" limit, or could it allowed to be fuzzy?

rick jones
