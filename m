From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: e1000 Invalid truesize
Date: Wed, 26 Apr 2006 08:24:45 -0700
Message-ID: <F50A4280B6033741B1DD2B4E902258B13F4EAD@orsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52606 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932480AbWDZPYs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 11:24:48 -0400
Content-class: urn:content-classes:message
To: "Jens Axboe" <axboe@suse.de>, <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please follow what has been happening on netdev.  Dave Miller added this
BUG to 2.6.17-rc as something we (Intel LAD) pointed out to them.  Jeff
Garzik has, as of this morning, queued our e1000 patch for this.  He's
been a little behind.

If you want to know more about the problem, please read the entire
netdev discussion about this.

Cheers,
John
-----------------------------------------------------------
"Those who would give up essential Liberty, to purchase a little
temporary Safety, deserve neither Liberty nor Safety.", Benjamin
Franklin 1755 


> -----Original Message-----
> From: Jens Axboe [mailto:axboe@suse.de] 
> Sent: Wednesday, April 26, 2006 7:25 AM
> To: netdev@vger.kernel.org
> Cc: Ronciak, John; Brandeburg, Jesse; Kirsher, Jeffrey T
> Subject: BUG: e1000 Invalid truesize
> 
> 
> Hi,
> 
> My problematic e1000 card (that sporadically gets transmit 
> timeouts with
> a driver newer than 2.6.14) hits new problems in current git 
> after this
> commit:
> 
>     [NET]: Add skb->truesize assertion checking.
> 
> I thought I'd mention it, since it may help fix the real problem.
> Basically I get tons of:
> 
> SKB BUG: Invalid truesize (592) len=712, sizeof(sk_buff)=208
> SKB BUG: Invalid truesize (592) len=448, sizeof(sk_buff)=208
> SKB BUG: Invalid truesize (592) len=712, sizeof(sk_buff)=208
> SKB BUG: Invalid truesize (592) len=448, sizeof(sk_buff)=208
> SKB BUG: Invalid truesize (592) len=500, sizeof(sk_buff)=208
> SKB BUG: Invalid truesize (592) len=500, sizeof(sk_buff)=208
> SKB BUG: Invalid truesize (592) len=500, sizeof(sk_buff)=208
> [...]
> 
> and some net connections don't work well. Putting the 2.6.14 
> driver back
> into current git makes things work smoothly, as always.
> 
> (Please be sure to cc me, I'm not on netdev)
> 
> -- 
> Jens Axboe
> 
