From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv2 net 1/3] openvswitch: Reject ct_state masks for unknown
 bits
Date: Sat, 17 Oct 2015 09:46:32 +0200
Message-ID: <20151017074632.GB13981@pox.localdomain>
References: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
 <1445018901-18839-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:33449 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666AbbJQHqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 03:46:34 -0400
Received: by wijp11 with SMTP id p11so37189473wij.0
        for <netdev@vger.kernel.org>; Sat, 17 Oct 2015 00:46:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445018901-18839-2-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/15 at 11:08am, Joe Stringer wrote:
> Currently, 0-bits are generated in ct_state where the bit position is
> undefined, and matches are accepted on these bit-positions. If userspace
> requests to match the 0-value for this bit then it may expect only a
> subset of traffic to match this value, whereas currently all packets
> will have this bit set to 0. Fix this by rejecting such masks.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Acked-by: Pravin B Shelar <pshelar@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
