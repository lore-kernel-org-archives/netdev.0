From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: A PMTU auto-discovery error for large SCTP packets
Date: Sun, 29 Jan 2017 12:39:43 -0200
Message-ID: <20170129143943.GL3781@localhost.localdomain>
References: <07B7943445653648AD9B4DBB916BB48F1C265220@cnshjmbx01>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>,
        "'network dev'" <netdev@vger.kernel.org>
To: YUAN Jia <Jia.Yuan@alcatel-sbell.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41230 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750982AbdA2OrV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 29 Jan 2017 09:47:21 -0500
Content-Disposition: inline
In-Reply-To: <07B7943445653648AD9B4DBB916BB48F1C265220@cnshjmbx01>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2017 at 06:40:10AM +0000, YUAN Jia wrote:
...
> I think that ‘sctp_manip_pkt’ should also behave like this. Isn’t it?

I believe so, yes.
Will you send a patch?

Btw, your host did have a MTU bigger than 1500, right? I'm just curious
on why such big packet was generated in the first place.

  Marcelo
