From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [Patch net-next v7 4/6] vxlan: add ipv6 support
Date: Tue, 30 Apr 2013 11:17:43 +0200
Message-ID: <87r4hscr7s.fsf@nemi.mork.no>
References: <1367311395-15891-1-git-send-email-amwang@redhat.com>
	<1367311395-15891-5-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53521 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759627Ab3D3JSH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 05:18:07 -0400
In-Reply-To: <1367311395-15891-5-git-send-email-amwang@redhat.com> (Cong
	Wang's message of "Tue, 30 Apr 2013 16:43:13 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> writes:

> +/* Create UDP socket for encapsulation receive. AF_INET6 socket
> + * could be used for both IPv4 and IPv6 communications.
> + */

This is not necessarily true as mentioned by David Stevens, and acked b=
y
you here: http://www.spinics.net/lists/netdev/msg234151.html

Please take your time to clean up your todo-list and *test* the result
with different runtime and buildtime settings. There is no need to rush
this, and people may get tired of looking at the same shortcomings over
and over again.



Bj=C3=B8rn
