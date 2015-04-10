From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 net-next] net_device: Reorder members to fill holes
Date: Fri, 10 Apr 2015 12:39:00 -0700
Message-ID: <1428694740.25985.327.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1428672434.git.tgraf@suug.ch>
	 <1df55f36edb4bd47a051e2664d243a3e91d29fb4.1428672434.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	daniel@iogearbox.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:37894 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbbDJTjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 15:39:03 -0400
Received: by igbqf9 with SMTP id qf9so6210564igb.1
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 12:39:02 -0700 (PDT)
In-Reply-To: <1df55f36edb4bd47a051e2664d243a3e91d29fb4.1428672434.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-10 at 15:52 +0200, Thomas Graf wrote:
> Some trivial reorders while preserving the RX/TX cache lines
> split to fill a couple of holes.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  include/linux/netdevice.h | 45 +++++++++++++++++++++------------------------
>  1 file changed, 21 insertions(+), 24 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Thomas !
