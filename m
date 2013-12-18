From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/2 v2] qlcnic: make local functions static
Date: Wed, 18 Dec 2013 13:58:39 -0800
Message-ID: <20131218135839.74010095@nehalam.linuxnetplumber.net>
References: <20131213123119.16358e1b@nehalam.linuxnetplumber.net>
	<1902752B0C92F943AB7EA9EE13E2DEEC1273B9F4A5@HQ1-EXCH02.corp.brocade.com>
	<20131218135438.71ea917f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:59931 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089Ab3LRV6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 16:58:41 -0500
Received: by mail-pa0-f45.google.com with SMTP id fb1so246200pad.32
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 13:58:41 -0800 (PST)
In-Reply-To: <20131218135438.71ea917f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Dec 2013 13:54:38 -0800
Stephen Hemminger <stephen@networkplumber.org> wrote:

> Functions only used in one file should be static.
> Found by running make namespacecheck
> 
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> ---
> v2 - update to latest net-next

Never mind, there is a duplicate declaration in here (won't compile).
Let me re-send with full cleanup bundle.
