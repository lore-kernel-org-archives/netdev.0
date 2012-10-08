From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC PATCH net-next] tcp: introduce tcp_tw_interval to specifiy
 the time of TIME-WAIT
Date: Mon, 08 Oct 2012 11:17:37 +0800
Message-ID: <1349666257.2707.6.camel@cr0>
References: <1348735261-29225-1-git-send-email-amwang@redhat.com>
	 <20120927142334.GA3194@neilslaptop.think-freely.org>
	 <1348813987.7264.41.camel@cr0>
	 <20120928131642.GA31568@hmsreliant.think-freely.org>
	 <1349161479.22107.17.camel@cr0>
	 <20121002120927.GA691@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10939 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211Ab2JHDSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2012 23:18:49 -0400
In-Reply-To: <20121002120927.GA691@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-02 at 08:09 -0400, Neil Horman wrote:
> No, its not very friendly, but the people using this are violating the RFC,
> which isn't very friendly. :)

Could you be more specific? In RFC 793, AFAIK, it is allowed to be
changed:

http://tools.ietf.org/html/rfc793

" To be sure that a TCP does not create a segment that carries a
  sequence number which may be duplicated by an old segment remaining in
  the network, the TCP must keep quiet for a maximum segment lifetime
  (MSL) before assigning any sequence numbers upon starting up or
  recovering from a crash in which memory of sequence numbers in use was
  lost.  For this specification the MSL is taken to be 2 minutes.  This
  is an engineering choice, and may be changed if experience indicates
  it is desirable to do so."

or I must still be missing something here... :)
