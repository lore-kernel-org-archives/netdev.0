From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] epic100: Test __BIG_ENDIAN instead of (non-existent)
 CONFIG_BIG_ENDIAN
Date: Wed, 02 Jun 2010 20:08:27 -0400
Message-ID: <4C06F27B.2080704@garzik.org>
References: <ada4ohlrx22.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.211.179]:48965 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932622Ab0FCAIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 20:08:34 -0400
Received: by ywh9 with SMTP id 9so5783479ywh.17
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 17:08:33 -0700 (PDT)
In-Reply-To: <ada4ohlrx22.fsf@roland-alpha.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/2010 04:36 PM, Roland Dreier wrote:
> Probably no one has used this driver on big-endian systems, since it was
> setting up descriptor swapping if CONFIG_BIG_ENDIAN is set, which it
> never is, since that symbol is not mentioned anywhere else in the kernel
> source.  Switch this test to a check for __BIG_ENDIAN so it has a chance
> at working.
>
> Signed-off-by: Roland Dreier<rolandd@cisco.com>

Acked-by: Jeff Garzik <jgarzik@redhat.com>


