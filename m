From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sat, 12 Feb 2005 12:28:38 -0800
Message-ID: <20050212122838.76cb838d.davem@davemloft.net>
References: <0525M9211@server5.heliogroup.fr>
	<420D37A3.6020209@hp.com>
	<20050211170958.17fcde21.davem@davemloft.net>
	<20050212143105.GB27456@yakov.inr.ac.ru>
	<86de38db09518ced8865af09cd79c064@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, romieu@fr.zoreil.com,
        hubert.tonneau@fullpliant.org, shemminger@osdl.org
To: rick jones <rick.jones2@hp.com>
In-Reply-To: <86de38db09518ced8865af09cd79c064@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 12 Feb 2005 12:19:35 -0800
rick jones <rick.jones2@hp.com> wrote:

> How is that?  Isn't cwnd based on the ACKs the sender receives from the 
> receiver?

ACKs go from sender to receiver, first of all.

It is based upon congestion as seen "by receiver", something which is
impossible for sender.
