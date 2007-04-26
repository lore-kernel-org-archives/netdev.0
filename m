From: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
Subject: Re: [RFC] RF Kill
Date: Thu, 26 Apr 2007 08:45:44 -0400
Message-ID: <d120d5000704260545p2acb0da9kf7217ba692f17513@mail.gmail.com>
References: <200704100158.58451.dtor@insightbb.com>
	 <200704100229.32393.dtor@insightbb.com>
	 <20070426.004951.85412315.davem@davemloft.net>
	 <20070426.005457.27951605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivdoorn@gmail.com, linville@tuxdriver.com,
	akpm@linux-foundation.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:1559 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030772AbXDZMpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 08:45:45 -0400
Received: by wr-out-0506.google.com with SMTP id 76so598324wra
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 05:45:45 -0700 (PDT)
In-Reply-To: <20070426.005457.27951605.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/26/07, David Miller <davem@davemloft.net> wrote:
>
> Actually, I'm reverting this, sorry.
>
> Besides the locking and other issues I pointed out, this
> thing won't even link.  Please do not test the build with
> various configurations when submitting new code like this.
>
> Thanks.
>
>  MODPOST 139 modules
> WARNING: "input_register_handle" [net/rfkill/rfkill-input.ko] undefined!
> WARNING: "input_unregister_handle" [net/rfkill/rfkill-input.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2
>

Argh, I forgot that this part of input core changes is not in mainline
yet. I am very sorry.

-- 
Dmitry
