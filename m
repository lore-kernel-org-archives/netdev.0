From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TCP Hang (or close to it):  Windows XP -> Linux (w/tcp_bic)
Date: Fri, 29 Oct 2004 11:00:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029110019.4f175979.davem@davemloft.net>
References: <200410290925.48955.dan.dickey@savvis.net>
	<Pine.LNX.4.58.0410291005100.3323@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dan.dickey@savvis.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0410291005100.3323@w-sridhar.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004 10:10:42 -0700 (PDT)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> This looks like the same TCP window overflow problem in 2.6.7 that came up a
> couple of days back.
> 
> See the thread
> 	http://marc.theaimsgroup.com/?t=109887532400001&r=1&w=2
> and the patch posted by davem.

Yes, and BTW for the original poster, BIC only effects sender
behavior whereas in your test case the Linux system with BIC
enabled is the receiver.
