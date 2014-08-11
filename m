From: "Sharma, Sanjeev" <Sanjeev_Sharma@mentor.com>
Subject: RE: [PATCH] smsc: replace WARN_ON() with WARN_ON_SMP()
Date: Mon, 11 Aug 2014 11:58:38 +0000
Message-ID: <FDC088D3B5555644AE135ED28A7ABDE94DF2B2C5@EU-MBX-02.mgc.mentorg.com>
References: <1407744983-29289-1-git-send-email-sanjeev_sharma@mentor.com>
 <20140811082015.GA1422@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "steve.glendinning@shawell.net" <steve.glendinning@shawell.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140811082015.GA1422@kroah.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok Greg probably Steve will have a look.

Regards
Sanjeev Sharma

-----Original Message-----
From: Greg KH [mailto:gregkh@linuxfoundation.org] 
Sent: Monday, August 11, 2014 1:50 PM
To: Sharma, Sanjeev
Cc: steve.glendinning@shawell.net; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: Re: [PATCH] smsc: replace WARN_ON() with WARN_ON_SMP()

On Mon, Aug 11, 2014 at 01:46:23PM +0530, Sanjeev Sharma wrote:
> spin_is_locked() always return false in uniprocessor configuration and 
> therefore it would be advise to repalce with WARN_ON_SMP().
> 
> Signed-off-by: Sanjeev Sharma <Sanjeev_Sharma@mentor.com>
> ---
>  drivers/net/ethernet/smsc/smsc911x.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Hint, I have nothing to do with this file, no need to send a patch for it to me, I can't do anything with it...

thanks,

greg k-h
