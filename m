From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: disablenetwork() syscall?
Date: Mon, 7 Jul 2003 22:52:15 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307072250000.11843-100000@netcore.fi>
References: <20030707194657.GA11328@gtf.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030707194657.GA11328@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 7 Jul 2003, Jeff Garzik wrote:
> On Mon, Jul 07, 2003 at 10:40:02PM +0300, Pekka Savola wrote:
> > In a bugtraq thread, DJ Bernstein brought up an idea which I'm not sure 
> > has been brought up in the past.  I'm not sure whether it's feasible or 
> > not, but at least it (and other methods to limit the functions of a 
> > user-level code) might bear consideration.
> 
> What about some URLs to what you are describing?
> 
> The most information you provided was in $subject, whose content
> makes me a bit leery...

Well, apart from the post scriptum, there was very little content about 
the feature/idea :-), and the details would seem to be up for everyone's 
imagination. 

FWIW, the body of the message is below:

=====
Richard M. Smith writes:
  [ mail readers disabling inline images ]
> It will be interesting to see how email marketing companies and
> spammers adapt to these technical changes in HTML email.
                                                                                                  
ASCII porn, perhaps? Especially if the sender can control the color, and
size, of text. I suppose those will be the next casualties in the war on
spam.
                                                                                                  
It's quite depressing that this is what people think of as ``security'':
patch maniacally; install a scanner that checks for yesterday's attacks;
don't view the pictures, don't drink the water, don't breathe the air.
                                                                                                  
I've been playing with a radically different system design (I'm thinking
of calling it ``UNIX'') where conceptually separate tasks are split into
separate processes. If you want to gunzip a stream of data, for example,
you run a gunzip program in its own chroot jail, under its own uid, with
no way to read any interesting data except through a predefined IPC hook
(I'm thinking of calling that a ``pipe'' on ``standard input'') and with
no way to touch anything except through another predefined IPC hook. The
only thing that an attacker can do by taking over this gunzip program is
generate arbitrary output data, which he could have done anyway. Typical
picture-generating programs can be isolated in the same way.
====

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
