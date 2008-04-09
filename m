From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH RFC 1/5] vringfd syscall
Date: Wed, 09 Apr 2008 14:28:05 -0500
Message-ID: <47FD18C5.6040709@goop.org>
References: <200804052202.09157.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Max Krasnyansky <maxk@qualcomm.com>,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:52827 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753648AbYDIT2l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 15:28:41 -0400
In-Reply-To: <200804052202.09157.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> +asmlinkage long sys_vringfd(void __user *addr,
> +			    unsigned num_descs,
> +			    u16 __user *last_used)
> +{
> +	int fd, err;
> +	struct file *filp;
> +	struct vring_info *vr;
> +
> +	/* Must be a power of two, and representable by u16 */
> +	if (!num_descs || (num_descs & (num_descs-1)) || num_descs > 65536) {
>   

65536 doesn't fit in u16.

    J
