From: netdev-bounce@oss.sgi.com
Subject: (no subject)
Date: Tue, 29 Oct 2002 14:19:40 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021029031940.6F43212C73F__46033.7300239646$1035919227@blammo.its.monash.edu.au>
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: undisclosed-recipients: ;
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bert hubert wrote:

> > ...adding the whole profile output - sorted by the first column this time...
> >
> > 905182 total                                      0.4741
> > 121426 csum_partial_copy_generic                474.3203
> >  93633 default_idle                             1800.6346
> >  74665 do_wp_page                               111.1086
> 
> Perhaps the 'copy' also entails grabbing the page from disk, leading to
> inflated csum_partial_copy_generic stats?

I think this is strictly a copy from user space->kernel and vice versa.
This shouldnt include the disk access etc. 

thanks,
Nivedita
