From: netdev-bounce@oss.sgi.com
Subject: (no subject)
Date: Tue, 29 Oct 2002 14:30:22 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021029033022.1B454130071__48499.3078899153$1035920193@splat.its.monash.edu.au>
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: undisclosed-recipients: ;
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
