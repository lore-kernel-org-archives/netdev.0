From: "Sharma, Sanjeev" <Sanjeev_Sharma@mentor.com>
Subject: RE: [PATCH] smsc: replace WARN_ON() with WARN_ON_SMP()
Date: Tue, 12 Aug 2014 05:22:46 +0000
Message-ID: <FDC088D3B5555644AE135ED28A7ABDE94DF2B3B6@EU-MBX-02.mgc.mentorg.com>
References: <1407744983-29289-1-git-send-email-sanjeev_sharma@mentor.com>
 <20140811.143842.1765285724858937860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"steve.glendinning@shawell.net" <steve.glendinning@shawell.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140811.143842.1765285724858937860.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks !

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Tuesday, August 12, 2014 3:09 AM
To: Sharma, Sanjeev
Cc: gregkh@linuxfoundation.org; steve.glendinning@shawell.net; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: Re: [PATCH] smsc: replace WARN_ON() with WARN_ON_SMP()

From: Sanjeev Sharma <sanjeev_sharma@mentor.com>
Date: Mon, 11 Aug 2014 13:46:23 +0530

> spin_is_locked() always return false in uniprocessor configuration and 
> therefore it would be advise to repalce with WARN_ON_SMP().
> 
> Signed-off-by: Sanjeev Sharma <Sanjeev_Sharma@mentor.com>

This looks fine, applied, thanks.
