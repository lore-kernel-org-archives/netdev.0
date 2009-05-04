From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] : CDC EEM driver patch to be applied to 2.6.30 kernel
Date: Mon, 4 May 2009 10:27:45 -0700
Message-ID: <200905041027.45948.david-b@pacbell.net>
References: <3a98b4410904270912g1838b534j2b53561b8caa1543@mail.gmail.com> <200905031713.58762.david-b@pacbell.net> <3a98b4410905040851i20d4192ax8f9ff3953e635979@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Omar Laazimani <omar.oberthur@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp125.sbc.mail.sp1.yahoo.com ([69.147.65.184]:32911 "HELO
	smtp125.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757482AbZEDR1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 13:27:48 -0400
In-Reply-To: <3a98b4410905040851i20d4192ax8f9ff3953e635979@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 04 May 2009, Omar Laazimani wrote:
> Thanks for your quick feedbacks.
> I have tested your patch with our device and it's working well.

Hmm, one more issue.  The eem_unbind() isn't needed at all,
is it??  It seems leftover from the ACM or ECM code, which
needed a separate control interface.  Nothing even sets up
the data used by that routine (other than zero-init).

- Dave
