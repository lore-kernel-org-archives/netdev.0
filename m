From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] smsc: replace WARN_ON() with WARN_ON_SMP()
Date: Mon, 11 Aug 2014 16:20:15 +0800
Message-ID: <20140811082015.GA1422@kroah.com>
References: <1407744983-29289-1-git-send-email-sanjeev_sharma@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sanjeev Sharma <sanjeev_sharma@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1407744983-29289-1-git-send-email-sanjeev_sharma@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 11, 2014 at 01:46:23PM +0530, Sanjeev Sharma wrote:
> spin_is_locked() always return false in uniprocessor configuration and therefore it
> would be advise to repalce with WARN_ON_SMP().
> 
> Signed-off-by: Sanjeev Sharma <Sanjeev_Sharma@mentor.com>
> ---
>  drivers/net/ethernet/smsc/smsc911x.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Hint, I have nothing to do with this file, no need to send a patch for
it to me, I can't do anything with it...

thanks,

greg k-h
