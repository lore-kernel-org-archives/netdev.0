From: Avi Kivity <avi@qumranet.com>
Subject: Re: [PATCH RFC 2/5] vringfd base/offset
Date: Sat, 05 Apr 2008 15:44:33 +0300
Message-ID: <47F77431.3030608@qumranet.com>
References: <200804052202.09157.rusty@rustcorp.com.au> <200804052204.28518.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Max Krasnyansky <maxk@qualcomm.com>,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bzq-179-150-194.static.bezeqint.net ([212.179.150.194]:51250
	"EHLO il.qumranet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752AbYDEMpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2008 08:45:00 -0400
In-Reply-To: <200804052204.28518.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> It turns out the lguest (and possibly kvm) want the addresses in the
> ring buffer to only cover a certain part of memory, and be offset.
>
>  					<mailto:rusty@rustcorp.com.au>	
> +0xAE	00-01	linux/vring.h
>   

Another virtualization subsystem already uses this range.


-- 
Any sufficiently difficult bug is indistinguishable from a feature.

