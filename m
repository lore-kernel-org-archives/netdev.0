From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sat, 12 Feb 2005 13:27:50 -0800
Message-ID: <420E74D6.3020100@us.ibm.com>
References: <0525M9211@server5.heliogroup.fr> <420D37A3.6020209@hp.com> <20050211170958.17fcde21.davem@davemloft.net> <20050212143105.GB27456@yakov.inr.ac.ru> <86de38db09518ced8865af09cd79c064@hp.com> <20050212205617.GA29146@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rick jones <rick.jones2@hp.com>, netdev@oss.sgi.com, romieu@fr.zoreil.com,
        hubert.tonneau@fullpliant.org, shemminger@osdl.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050212205617.GA29146@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov wrote:

> If receiver sent an ACK it still does not mean that sender used it
> to increase its cwnd. Particularly, small packet exchange definitely
> does not inflate cwnd.

Simplest way to go about this is simply compare it to the
trace of the "good/fast" connection - Hubert, could you
provide the "good" trace as well? That would show where
the differences in time are taken up..

thanks,
Nivedita
