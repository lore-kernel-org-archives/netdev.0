From: Roy Sigurd Karlsbakk <roy@karlsbakk.net>
Subject: O_DIRECT sockets? (was [RESEND] tuning linux for high network performance?)
Date: Wed, 23 Oct 2002 17:26:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210231726.21135.roy@karlsbakk.net>
References: <200210231218.18733.roy@karlsbakk.net> <20021023130101.GA646@outpost.ds9a.nl> <3DB6B96F.A0DE47BF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>, bert hubert <ahu@ds9a.nl>
In-Reply-To: <3DB6B96F.A0DE47BF@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 23 October 2002 16:59, Nivedita Singhvi wrote:
> bert hubert wrote:
> > > ...adding the whole profile output - sorted by the first column this
> > > time...
> > >
> > > 905182 total                                      0.4741
> > > 121426 csum_partial_copy_generic                474.3203
> > >  93633 default_idle                             1800.6346
> > >  74665 do_wp_page                               111.1086
> >
> > Perhaps the 'copy' also entails grabbing the page from disk, leading to
> > inflated csum_partial_copy_generic stats?
>
> I think this is strictly a copy from user space->kernel and vice versa.
> This shouldnt include the disk access etc.

hm

I'm doing O_DIRECT read (from disk), so it needs to be user -> kernel, then.

any chance of using O_DIRECT to the socket?

-- 
Roy Sigurd Karlsbakk, Datavaktmester
ProntoTV AS - http://www.pronto.tv/
Tel: +47 9801 3356

Computers are like air conditioners.
They stop working when you open Windows.
