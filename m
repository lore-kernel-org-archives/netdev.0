From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH][BLUETOOTH] kill bt_sock_alloc
Date: Wed, 9 Mar 2005 15:43:15 -0300
Message-ID: <20050309184314.GA29053@conectiva.com.br>
References: <20050308094937.GA9468@conectiva.com.br> <20050308095209.GB9468@conectiva.com.br> <422F33E9.4030401@qualcomm.com> <1110392653.5462.40.camel@notepaq>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Max Krasnyansky <maxk@qualcomm.com>, davem@davemloft.net,
        netdev@oss.sgi.com
To: Marcel Holtmann <marcel@holtmann.org>
Content-Disposition: inline
In-Reply-To: <1110392653.5462.40.camel@notepaq>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, Mar 09, 2005 at 07:24:13PM +0100, Marcel Holtmann escreveu:
> Hi Max,
> 
> > > Sorry, now with the patch attached.
> > 
> > Looks good to me. Marcel I'd suggest for you to apply this patch.
> > It helps in reducing overall size of the socket structures.
> 
> I didn't got the time to review and test it. Will do that next week.

OK, take your time, but the changes are rather small, I left renaming
all the _pinfo (l2cap_pinfo, for instance) to _sock (for consistency
with all the other net families) to keep the patch small. 

For now I'll work on doing this same change to the HAM radio protocols,
coordinating with Ralf Baechle and then wait for your comments to finally
kill sk_protinfo and move on to introduce struct connection_sock.

- Arnaldo
