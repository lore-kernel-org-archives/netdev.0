From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] sock: don't enable netstamp for af_unix sockets
Date: Mon, 26 Oct 2015 14:19:28 +0100
Message-ID: <20151026131928.GA1820@netboy>
References: <1445863897-22646-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37551 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753463AbbJZNTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 09:19:33 -0400
Received: by wicfv8 with SMTP id fv8so115663072wic.0
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 06:19:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445863897-22646-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 26, 2015 at 01:51:37PM +0100, Hannes Frederic Sowa wrote:
> netstamp_needed is toggled for all socket families if they request
> timestamping. But some protocols don't need the lower-layer timestamping
> code at all. This patch starts disabling it for af-unix.

What problem is this patch trying to solve?

Thanks,
Richard
