From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 20 Sep 2004 08:54:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414EFD2A.5000805@us.ibm.com>
References: <20040920063012.GL2825@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20040920063012.GL2825@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Anton Blanchard wrote:
> Hi,
> 
> I just tried latest 2.6.9-rc2-BK on a machine with an e1000 on it. With
> TSO off it does about 100MB/sec. With TSO on it does between 1MB/sec and
> 10MB/sec.

Hey Anton,  yep, I was just debugging this. TSO mainline reworked
implementation is still not cooked. Don't worry, final state won't
be this bad :).

Could you echo 0 > /proc/sys/net/ipv4/tcp_bic and redo test,
please?
