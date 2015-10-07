From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v2 4/5] random32: add prandom_init_once helper
 for own rngs
Date: Wed, 7 Oct 2015 16:54:36 -0700
Message-ID: <5615B0BC.7030005@plumgrid.com>
References: <cover.1444258405.git.daniel@iogearbox.net>
 <7852684945acede41915662c1cbc6a83904e5d57.1444258406.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33034 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670AbbJGXyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 19:54:38 -0400
Received: by pacex6 with SMTP id ex6so35239664pac.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 16:54:38 -0700 (PDT)
In-Reply-To: <7852684945acede41915662c1cbc6a83904e5d57.1444258406.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/7/15 4:20 PM, Daniel Borkmann wrote:
> Add a prandom_init_once() facility that works on the rnd_state, so that
> users that are keeping their own state independent from prandom_u32() can
> initialize their taus113 per cpu states.
>
> The motivation here is similar to net_get_random_once(): initialize the
> state as late as possible in the hope that enough entropy has been
> collected for the seeding. prandom_init_once() makes use of the recently
> introduced prandom_seed_full_state() helper and is generic enough so that
> it could also be used on fast-paths due to the DO_ONCE().
>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>
> Acked-by: Hannes Frederic Sowa<hannes@stressinduktion.org>

Acked-by: Alexei Starovoitov <ast@kernel.org>
