From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH] IPV4: spelling correction
Date: Tue, 10 Feb 2004 10:30:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040210103050.63643c9a.rddunlap@osdl.org>
References: <20040211.032831.67897970.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040211.032831.67897970.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Feb 2004 03:28:31 +0900 (JST) YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

a few comments (beginning with "**").


| D: spelling correction for net/ipv4
| 
| ===== net/ipv4/tcp_input.c 1.49 vs edited =====
| --- 1.49/net/ipv4/tcp_input.c	Mon Feb  2 04:22:45 2004
| +++ edited/net/ipv4/tcp_input.c	Wed Feb 11 03:10:02 2004
| @@ -392,7 +392,7 @@
|  			if (tp->ack.ato > tp->rto)
|  				tp->ack.ato = tp->rto;
|  		} else if (m > tp->rto) {
| -			/* Too long gap. Apparently sender falled to
| +			/* Too long gap. Apparently sender fellen to
**                                                         failed
|  			 * restart window, so that we send ACKs quickly.
|  			 */
|  			tcp_incr_quickack(tp);
| @@ -431,7 +431,7 @@
|  	 *
|  	 * Funny. This algorithm seems to be very broken.
|  	 * These formulae increase RTO, when it should be decreased, increase
| -	 * too slowly, when it should be incresed fastly, decrease too fastly
| +	 * too slowly, when it should be increased fastly, decrease too fastly
** s/fastly/quickly/ or s/fastly/fast/

|  	 * etc. I guess in BSD RTO takes ONE value, so that it is absolutely
|  	 * does not matter how to _calculate_ it. Seems, it was trap
|  	 * that VJ failed to avoid. 8)
| @@ -493,14 +493,14 @@
|  	tp->rto = (tp->srtt >> 3) + tp->rttvar;
|  
|  	/* 2. Fixups made earlier cannot be right.
|  	 *    If we do not estimate RTO correctly without them,
|  	 *    all the algo is pure shit and should be replaced
| -	 *    with correct one. It is exaclty, which we pretend to do.
| +	 *    with correct one. It is exactly, which we pretend to do.
**                                           ^ what  (delete comma)

|  	 */
|  }
|  
| -- 
| Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
| GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA


--
~Randy
