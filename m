From: netdev-bounce@oss.sgi.com
Subject: (no subject)
Date: Tue, 29 Oct 2002 15:45:07 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021029044507.A18D012C5A5@blammo.its.monash.edu.au>
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: undisclosed-recipients: ;
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> '50 clients *each* streaming at ~4.4MBps', better make that clear,
> otherwise something is *very* broken. Also mention that you have an e1000
> card which does not do outgoing checksumming.

just to clearify

s/MBps/Mbps/
s/bps/bits per second/

> You'd think that a kernel would be able to do 250megabits of TCP checksums
> though.
>
> > ...adding the whole profile output - sorted by the first column this
> > time...
> >
> > 905182 total                                      0.4741
> > 121426 csum_partial_copy_generic                474.3203
> >  93633 default_idle                             1800.6346
> >  74665 do_wp_page                               111.1086
>
> Perhaps the 'copy' also entails grabbing the page from disk, leading to
> inflated csum_partial_copy_generic stats?

I really don't know. Just to clearify a little more - the server app uses 
O_DIRECT to read the data before tossing it to the socket.

> Where are you serving from?

What do you mean?

roy
-- 
Roy Sigurd Karlsbakk, Datavaktmester
ProntoTV AS - http://www.pronto.tv/
Tel: +47 9801 3356

Computers are like air conditioners.
They stop working when you open Windows.
