From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: TCP Retx per tcp-flow
Date: Fri, 21 Nov 2003 23:00:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBF09A7.208@us.ibm.com>
References: <20031122020527.3f98f772.bedboi@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bedboi <bedboi@gmx.net>
In-Reply-To: <20031122020527.3f98f772.bedboi@gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bedboi wrote:
> Hi guys. I'm comparing TCP with a new congestion control algorithm and i need to get the number
> of segments retransmitted for a specific TCP flow. Is there a way to do this? (please don't tell
> man tcpdump...ok you'll tell it)


Tried tcp_info.tcpi_retransmits?
getsockopt() at SOL_TCP level and option TCP_INFO.


thanks,
Nivedita
