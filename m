From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] select: fix sys_select to not leak ERESTARTNOHAND to userspace
Date: Tue, 23 Jan 2007 10:02:49 +1100
Message-ID: <200701231002.49615.ak@suse.de>
References: <20070122130020.GA21059@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33590 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932281AbXAVXHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 18:07:44 -0500
To: Neil Horman <nhorman@tuxdriver.com>
In-Reply-To: <20070122130020.GA21059@hmsreliant.homelinux.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 23 January 2007 00:00, Neil Horman wrote:
> As it is currently written, sys_select checks its return code to convert
> ERESTARTNOHAND to EINTR.  However, the check is within an if (tvp) clause,
> and so if select is called from userspace with a NULL timeval, then it is
> possible for the ERESTARTNOHAND errno to leak into userspace, which is
> incorrect.  This patch moves that check outside of the conditional, and
> prevents the errno leak.


Patch looks good to me.

-Andi
