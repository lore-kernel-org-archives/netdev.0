From: cranium2003 <cranium2003@yahoo.com>
Subject: Re: how netfilter handles fragmented packets
Date: Mon, 22 Nov 2004 22:07:10 -0800 (PST)
Message-ID: <20041123060710.35447.qmail@web41406.mail.yahoo.com>
References: <29495f1d04112211554e78da67@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernelnewbies@nl.linux.org, linux-kernel@vger.kernel.org,
  netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <kernelnewbies-bounce@nl.linux.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
In-Reply-To: <29495f1d04112211554e78da67@mail.gmail.com>
Sender: kernelnewbies-bounce@nl.linux.org
Errors-to: kernelnewbies-bounce@nl.linux.org
List-help: <mailto:ecartis@nl.linux.org?Subject=help>
List-unsubscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=unsubscribe>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=subscribe>
List-owner: <mailto:ecartis-owner@nl.linux.org>
List-post: <mailto:kernelnewbies@nl.linux.org>
List-archive: <http://mail.nl.linux.org/kernelnewbies/>
List-Id: netdev.vger.kernel.org

Hello Nish,
          Thanks. I got it. dump_stack is implemented
in trap.c file in kernel source. 
          what i decide to use dump_stack is to do
pinging to myself at one console and same time call
dump_stack from user program. Is that right? But where
is output displayed? Dose that help me to find out
which function is called by output(skb).
          
regards,
cranium.


--- Nish Aravamudan <nish.aravamudan@gmail.com> wrote:

> On Sun, 21 Nov 2004 11:42:02 -0800 (PST),
> cranium2003
> <cranium2003@yahoo.com> wrote:
> > 
> > --- Nish Aravamudan <nish.aravamudan@gmail.com>
> wrote:
> > Hello Nish,
> > 
> > 
> > 
> > > On Sun, 21 Nov 2004 17:15:12 +0100 (MET), Jan
> > > Engelhardt
> > > <jengelh@linux01.gwdg.de> wrote:
> > > > >hello,
> > > > >          In ip_output.c file ip_fragmet
> function
> > > when
> > > > >create a new fragmented packet given to
> > > output(skb)
> > > > >function. i want to know which function are
> > > actually
> > > > >called by output(skb)?
> > > >
> > > > use stack_dump() (or was it dump_stack()?)
> > >
> > > dump_stack(), if you want to dump the current
> > > process' stack context.
> > >
> > > -Nish
> > >
> > 
> > can you please tell me how can i use dump_stack()
> > method? so using dump_stack i will come to know
> which
> > function will be called by output(skb) right? But
> > where i get dump_stack()???
> 
> Last time i used it, I didn't need to do a darn
> thing. I believe it's
> part of the traps code, so you can just call
> dump_stack().
> dump_stack() will throw out the trace of the current
> task's stack at
> the point when it is called. See what happens when
> you place it in
> different places. Another option, if you ever have a
> hanging sytem is
> Alt-SysRq-T (presuming you have the magic option
> enabled and you are
> able to scrollback still), which pretty much calls
> dump_stack() for
> all available processes.
> 
> -Nish
> 
> --
> Kernelnewbies: Help each other learn about the Linux
> kernel.
> Archive:      
> http://mail.nl.linux.org/kernelnewbies/
> FAQ:           http://kernelnewbies.org/faq/
> 
> 



		
__________________________________ 
Do you Yahoo!? 
Meet the all-new My Yahoo! - Try it today! 
http://my.yahoo.com 
 


--
Kernelnewbies: Help each other learn about the Linux kernel.
Archive:       http://mail.nl.linux.org/kernelnewbies/
FAQ:           http://kernelnewbies.org/faq/
