From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: where is the proper place for r8169 bug reports?
Date: Tue, 1 Feb 2005 23:31:09 +0100
Message-ID: <20050201223109.GA2957@electric-eye.fr.zoreil.com>
References: <20050131181508.GA15908@gerbil.toadis.porkis> <20050131214951.GA13217@electric-eye.fr.zoreil.com> <20050131215948.GA23289@gerbil.toadis.porkis> <20050131222342.GB13217@electric-eye.fr.zoreil.com> <20050201215607.GA8530@gerbil.toadis.porkis>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "Dale E. Martin" <dale@the-martins.org>
Content-Disposition: inline
In-Reply-To: <20050201215607.GA8530@gerbil.toadis.porkis>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dale E. Martin <dale@the-martins.org> :
[...]
> although it looks like the card is only found on cold boots.

Can you send (or put on a webpage) the same dmesg and lspci -vx when
it happens ?

> The irony of this, btw, is that linux/Documentation/Changes still
> recommends gcc 2.95.3 - even in version 2.6.8, possibly in 2.6.10.  (I
> think I saw it in there but I don't have it handy.)

You saw it there. No comment.

> Also, when I first started looking at this, I tried to #define
> RTL8169_DEBUG but was getting compile errors.  Should I file a bug about
> this ?

I lost this one. Re-added to the queue. Don't bother with a PR for it.

[...]
> It looks like the poor 1Ghz C3 in this machine is going to be the
> bottleneck for getting good transfer rates over gigabit ethernet ;-)

It depends on the kind of transfer. A bigger MTU really helps. So does
TSO and checksumming but it is really dependant on the kind of load.
This is the content of the patch against 2.4.28.

[...]
> What is the intention of this patch?  Is it to handle the 2.95.x issue or
> something else ?

See above. Can you:
- send me discretly the .o built from the r8169 sources with 2.95.3 ?
- pest me until you have a 2.95.3 compiled r8169 module which does not
  lock up any more ?

--
Ueimor
