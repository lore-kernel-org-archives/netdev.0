From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] [NETLABEL] Minor cleanup: remove unused method definition
Date: Tue, 19 Feb 2008 11:08:27 -0500
Message-ID: <200802191108.27168.paul.moore@hp.com>
References: <eb3ff54b0802190625v5315aac9m7ffd580b30bce8cd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	casey@schaufler-ca.com
To: "Rami Rosen" <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:13662 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415AbYBSQIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 11:08:32 -0500
In-Reply-To: <eb3ff54b0802190625v5315aac9m7ffd580b30bce8cd@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 19 February 2008 9:25:31 am Rami Rosen wrote:
> Hi,
>
> This patch removes definition of netlbl_cfg_cipsov4_del() method in
> netlabel/netlabel_kapi.c and in include/net/netlabel.h as it is not
> used.
>
>
> Regards,
> Rami Rosen
>
>
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

This was added for use by Smack (and any other LSMs which want to 
configure NetLabel directly) and since this is an area that is 
undergoing a lot of churn at this point I'd prefer if this function was 
left in place for the time being.

At a later date if this function is still unused, I'll gladly ack it's 
removal or do so myself.

-- 
paul moore
linux security @ hp
