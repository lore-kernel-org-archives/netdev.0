From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sat, 12 Feb 2005 11:28:11 -0800
Message-ID: <20050212112811.13a0b97d.davem@davemloft.net>
References: <0525M9211@server5.heliogroup.fr>
	<420D37A3.6020209@hp.com>
	<20050211170958.17fcde21.davem@davemloft.net>
	<20050212143105.GB27456@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, hubert.tonneau@fullpliant.org, shemminger@osdl.org,
        romieu@fr.zoreil.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050212143105.GB27456@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 12 Feb 2005 17:31:05 +0300
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

> In any case, receiver cannot know sender cwnd, so that "fill" or "not fill"
> is is not a question.
>
> What is broken in that implementation is that it does not feel slow start.
> ACK avoidance while slow start is certain disaster. Currrent theory is that
> MacOS X thinks that we do not do slow start.

It is correct.  Although, I am still believing that setting PSH
is the avenue of investigation.
