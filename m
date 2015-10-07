From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v2 2/5] once: make helper generic for calling
 functions once
Date: Wed, 7 Oct 2015 16:52:56 -0700
Message-ID: <5615B058.2010804@plumgrid.com>
References: <cover.1444258405.git.daniel@iogearbox.net>
 <9a27fef5de706382e07d92807a2acaad10055382.1444258406.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34229 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557AbbJGXw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 19:52:58 -0400
Received: by padhy16 with SMTP id hy16so35143537pad.1
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 16:52:58 -0700 (PDT)
In-Reply-To: <9a27fef5de706382e07d92807a2acaad10055382.1444258406.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/7/15 4:20 PM, Daniel Borkmann wrote:
> From: Hannes Frederic Sowa<hannes@stressinduktion.org>
>
> Make the get_random_once() helper generic enough, so that functions
> in general would only be called once, where one user of this is then
> net_get_random_once().
>
> The only implementation specific call is to get_random_bytes(), all
> the rest of this *_once() facility would be duplicated among different
> subsystems otherwise. The new DO_ONCE() helper will be used by prandom()
> later on, but might also be useful for other scenarios/subsystems as
> well where a one-time initialization in often-called, possibly fast
> path code could occur.
>
> Signed-off-by: Hannes Frederic Sowa<hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>

nice! you even added sparse tags.
Acked-by: Alexei Starovoitov <ast@kernel.org>
