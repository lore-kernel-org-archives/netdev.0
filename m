From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc: fix compilation with old gcc (< 4.6)
Date: Mon, 11 Jan 2016 08:28:00 -0800
Message-ID: <20160111082800.611a9201@xeon-e3>
References: <1452171793-5829-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	daniel@iogearbox.net, Julien Floret <julien.floret@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36431 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757960AbcAKQ1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 11:27:53 -0500
Received: by mail-pf0-f180.google.com with SMTP id n128so46952921pfn.3
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 08:27:52 -0800 (PST)
In-Reply-To: <1452171793-5829-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  7 Jan 2016 14:03:13 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> From: Julien Floret <julien.floret@6wind.com>
> 
> gcc < 4.6 does not handle C11 syntax for the static initialization of
> anonymous struct/union, hence the following error:
> 
> tc_bpf.c:260: error: unknown field map_type specified in initializer
> 
> Signed-off-by: Julien Floret <julien.floret@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.
