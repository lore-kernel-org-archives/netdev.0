From: Roy Sigurd Karlsbakk <roy@karlsbakk.net>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: Wed, 23 Oct 2002 15:41:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210231541.02883.roy@karlsbakk.net>
References: <200210231218.18733.roy@karlsbakk.net> <200210231306.18422.roy@karlsbakk.net> <20021023130101.GA646@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20021023130101.GA646@outpost.ds9a.nl>
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
