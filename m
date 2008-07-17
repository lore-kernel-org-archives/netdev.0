From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [Resend PATCH 1/3] TCP: Fix MD5 signatures for non-linear skbs
Date: Thu, 17 Jul 2008 16:03:35 -0700
Message-ID: <396556a20807171603q1b3c79e7nac39f717d7cb4965@mail.gmail.com>
References: <396556a20805301217k293e5718h6bbf02bfe069011@europa>
	 <20080716.204040.127241370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:9320 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672AbYGQXDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 19:03:39 -0400
Received: by py-out-1112.google.com with SMTP id p76so93891pyb.10
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 16:03:36 -0700 (PDT)
In-Reply-To: <20080716.204040.127241370.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2008 at 8:40 PM, David Miller <davem@davemloft.net> wrote:
> You don't have any module exports for these functions,
> yet they are called from tcp_ipv6.c, and that will cause
> a build failure.

Added these then tested building IPv6 as a module and inserting it.

Cheers


AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
