From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: Wed, 23 Oct 2002 07:59:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB6B96F.A0DE47BF@us.ibm.com>
References: <200210231218.18733.roy@karlsbakk.net> <200210231306.18422.roy@karlsbakk.net> <20021023130101.GA646@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Roy Sigurd Karlsbakk <roy@karlsbakk.net>, netdev@oss.sgi.com,
   Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
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
