From: "David S. Miller" <davem@davemloft.net>
Subject: Re: slow tcp acks on loopback device
Date: Fri, 22 Jul 2005 13:08:16 -0700 (PDT)
Message-ID: <20050722.130816.91445335.davem@davemloft.net>
References: <1122062219.29258.12.camel@stevef95.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samba-technical@lists.samba.org,
	linux-kernel@vger.kernel.org
Return-path: <samba-technical-bounces+gnsi-samba-technical=m.gmane.org@lists.samba.org>
To: smfltc@us.ibm.com
In-Reply-To: <1122062219.29258.12.camel@stevef95.austin.ibm.com>
List-Unsubscribe: <https://lists.samba.org/mailman/listinfo/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/archive/samba-technical>
List-Post: <mailto:samba-technical@lists.samba.org>
List-Help: <mailto:samba-technical-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=subscribe>
Sender: samba-technical-bounces+gnsi-samba-technical=m.gmane.org@lists.samba.org
Errors-To: samba-technical-bounces+gnsi-samba-technical=m.gmane.org@lists.samba.org
List-Id: netdev.vger.kernel.org

From: Steve French <smfltc@us.ibm.com>
Date: 22 Jul 2005 14:56:59 -0500

> Noticing that the loopback device (at least on RHEL4) has an unfortunate
> mtu size 16384 (which is about 50 bytes too small for SMB read
> responses), I did try increasing the MTU slightly.  Changing that to
> 18000 did avoid the fragmentation and the 40ms delay - but what puzzled
> me was why setting TCP_NODELAY after the socket was created did not
> eliminate the delay on the ack and if there is a way to avoid the huge
> tcp ack delay by either doing something else to force client acking
> immediately or to do something on the client side of the stack to get
> the server to send the whole 16K+ frame - it looks like the tcp windows
> is 32K if the value in the tcp acks in the network trace is to be
> trusted.

TCP_NODELAY does not control ACK generation, instead it modifies
the Nagle algorithm behavior when sending data packets.

Please take networking discussions to netdev@vger.kernel.org which
is where the networking developers are.
