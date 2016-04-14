From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] sock: tigthen lockdep checks for
 sock_owned_by_user
Date: Wed, 13 Apr 2016 22:43:36 -0400 (EDT)
Message-ID: <20160413.224336.614846243301591836.davem@davemloft.net>
References: <1460121087-2859-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1460121087-2859-1-git-send-email-hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Date: Fri,  8 Apr 2016 15:11:27 +0200

> sock_owned_by_user should not be used without socket lock held. It seems
> to be a common practice to check .owned before lock reclassification, so
> provide a little help to abstract this check away.
> 
> Cc: linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>

Applied.
