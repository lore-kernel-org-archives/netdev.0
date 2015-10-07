From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v2 3/5] random32: add prandom_seed_full_state
 helper
Date: Wed, 7 Oct 2015 16:54:13 -0700
Message-ID: <5615B0A5.1060907@plumgrid.com>
References: <cover.1444258405.git.daniel@iogearbox.net>
 <50d520dd9e123a893fcddfb76f7645ebc49ee4bd.1444258406.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35348 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753036AbbJGXyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 19:54:15 -0400
Received: by pacfv12 with SMTP id fv12so35919513pac.2
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 16:54:14 -0700 (PDT)
In-Reply-To: <50d520dd9e123a893fcddfb76f7645ebc49ee4bd.1444258406.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/7/15 4:20 PM, Daniel Borkmann wrote:
> Factor out the full reseed handling code that populates the state
> through get_random_bytes() and runs prandom_warmup(). The resulting
> prandom_seed_full_state() will be used later on in more than the
> current __prandom_reseed() user. Fix also two minor whitespace
> issues along the way.
>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>
> Acked-by: Hannes Frederic Sowa<hannes@stressinduktion.org>

Acked-by: Alexei Starovoitov <ast@kernel.org>
