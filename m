From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH][BLUETOOTH] kill bt_sock_alloc
Date: Thu, 10 Mar 2005 20:51:03 +0100
Message-ID: <1110484263.8395.6.camel@pegasus>
References: <20050308094937.GA9468@conectiva.com.br>
	 <20050308095209.GB9468@conectiva.com.br> <422F33E9.4030401@qualcomm.com>
	 <1110392653.5462.40.camel@notepaq>
	 <20050309184314.GA29053@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Network Development Mailing List <netdev@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20050309184314.GA29053@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Arnaldo,

> > > Looks good to me. Marcel I'd suggest for you to apply this patch.
> > > It helps in reducing overall size of the socket structures.
> > 
> > I didn't got the time to review and test it. Will do that next week.
> 
> OK, take your time, but the changes are rather small, I left renaming
> all the _pinfo (l2cap_pinfo, for instance) to _sock (for consistency
> with all the other net families) to keep the patch small. 

the patch is fine so far, but you forgot to change cmtp/sock.c. Please
do this and resend it.

Send a second patch on top this one which is doing the renaming from
*_pinfo to *_sock. I am fine with the renaming, but I like to have this
in two separate patches.

> For now I'll work on doing this same change to the HAM radio protocols,
> coordinating with Ralf Baechle and then wait for your comments to finally
> kill sk_protinfo and move on to introduce struct connection_sock.

When doing this, please split these changes into patches for
net/bluetooth/, net/bluetooth/rfcomm/ and net/bluetooth/*/.

Regards

Marcel
