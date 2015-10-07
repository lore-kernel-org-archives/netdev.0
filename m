From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v2 1/5] net: move net_get_random_once to lib
Date: Wed, 7 Oct 2015 16:55:08 -0700
Message-ID: <5615B0DC.1060000@plumgrid.com>
References: <cover.1444258405.git.daniel@iogearbox.net>
 <0c4ba1bd57bebe9d4cf2cd7a7fdcb2655fe642e9.1444258405.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36766 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349AbbJGXzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 19:55:11 -0400
Received: by pablk4 with SMTP id lk4so35124573pab.3
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 16:55:11 -0700 (PDT)
In-Reply-To: <0c4ba1bd57bebe9d4cf2cd7a7fdcb2655fe642e9.1444258405.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/7/15 4:20 PM, Daniel Borkmann wrote:
> From: Hannes Frederic Sowa<hannes@stressinduktion.org>
>
> There's no good reason why users outside of networking should not
> be using this facility, f.e. for initializing their seeds.
>
> Therefore, make it accessible from there as get_random_once().
>
> Signed-off-by: Hannes Frederic Sowa<hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
