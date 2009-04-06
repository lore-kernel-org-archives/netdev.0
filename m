From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: Multicast packet loss
Date: Mon, 06 Apr 2009 18:12:42 -0400
Message-ID: <49DA7E5A.6070904@athenacr.com>
References: <49B4B909.7050002@cosmosbay.com>	<20090313.145152.121603300.davem@davemloft.net>	<49BADE87.40407@cosmosbay.com> <20090313.153851.11725991.davem@davemloft.net> <49BED109.3020504@cosmosbay.com> <49D66379.7070106@athenacr.com> <49D8B6DA.7050902@cosmosbay.com> <49DA79EF.5010509@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:1060 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752601AbZDFWMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 18:12:47 -0400
In-Reply-To: <49DA79EF.5010509@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Bloniarz wrote:
>     BUG_ON(!spin_is_locked(&sk->sk_lock.slock));

Oh, sorry, I think I'm just misunderstanding how the socket
lock works. This doesn't actually check that the socket is locked,
right?

-Brian
