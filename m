From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Fri, 11 Feb 2005 17:09:58 -0800
Message-ID: <20050211170958.17fcde21.davem@davemloft.net>
References: <0525M9211@server5.heliogroup.fr>
	<420D37A3.6020209@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hubert.tonneau@fullpliant.org, shemminger@osdl.org, romieu@fr.zoreil.com,
        kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <420D37A3.6020209@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Feb 2005 14:54:27 -0800
Rick Jones <rick.jones2@hp.com> wrote:

> In some cases at least if the sender does not completely fill cwnd the
> ACKs will  be delayed.  And IIRC under 2.6.10 with TSO enabled, the
> sender does not always  fill cwnd.

At a maximum, "1/tcp_tso_win_divisor" of the cwnd will ever be left
empty.

By default, this is 1/8 of the cwnd.
