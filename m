From: Jesper Dangaard Brouer via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: XDP (eXpress Data Path) documentation
Date: Thu, 22 Sep 2016 12:01:54 +0200
Message-ID: <20160922120154.25d0fec7@redhat.com>
References: <20160920110844.661965be@redhat.com>
	<CALx6S37W2qfceOUDnPvFM5PuGp4G3cWjgrQP5_W9Veosic61pw@mail.gmail.com>
Reply-To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nathan Willis <nate-T1hC0tSOHrs@public.gmane.org>, Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org" <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <CALx6S37W2qfceOUDnPvFM5PuGp4G3cWjgrQP5_W9Veosic61pw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Sep 2016 17:03:24 -0700
Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org> wrote:

> On Tue, Sep 20, 2016 at 2:08 AM, Jesper Dangaard Brouer
> <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > Hi all,
> >
> > As promised, I've started documenting the XDP eXpress Data Path):
> >
> >  [1] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/index.html
> >
> > IMHO the documentation have reached a stage where it is useful for the
> > XDP project, BUT I request collaboration on improving the documentation
> > from all. (Native English speakers are encouraged to send grammar fixes ;-))
> >  
> Hi Jesper,
> 
> Thanks for taking the initiative on the this, The document reads more
> like a design doc than description right now, that's probably okay
> since we could use a design doc.

Yes, I fully agree.

I want to state very clearly, this document is not an attempt to hijack
the XDP project and control the "spec".  This is an attempt to collaborate.
We discuss things on the mailing list, each with our own vision of the
project, and most times we reach an agreement. But nobody document this
agreement. 

Month later, we make implementation choices that goes against these
agreements, because we simply forgot.  If someone remembers, we have to
reiterate the same arguments again (like it just happened with the
XDP_ABORTED action, my mistake).  And can anybody remember the
consensus around VLANs, it never got implemented that way...

I had to start the doc project somewhere, so I dumped my own vision
into the docs, and what I could remember from upstream discussions.
I need collaboration from others to adjust and "fix" my vision of the
project, into something that becomes a common ground we all can agree
on.

If some part of the docs provoke you, good, then you have a reason to
correct and fix it.  I'll do my best to keep an very open-mind about
any changes.  This should be a very "live" document.  


> Under "Important to understand" there are some disclaimers that XDP
> does not implement qdiscs or BQL and fairness otherwise. This is true
> for it's own traffic, but it does not (or at least should not) affect
> these mechanisms or normal stack traffic running simultaneously. I
> think we've made assumptions about fairness between XDP and non-XDP
> queues, we probably want to clarify fairness (and also validate
> whatever assumptions we've made with testing).

I love people pointing out mistakes in the documentation.  I want
update this ASAP when people point it out.  I'll even do the work of
integrating and committing these changes, for people too lazy to git
clone the repo themselves.

For you section Tom, I fully agree, but I don't know how to formulate
and adjust this in the text.

For people that want to edit the docs, notice the link "Edit on GitHub"
which takes you directly to the file you need to edit...



> > You wouldn't believe it: But this pretty looking documentation actually
> > follows the new Kernel documentation format.  It is actually just
> > ".rst" text files stored in my github repository under kernel/Documentation [2]
> >
> >  [2] https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/Documentation
> >
> > Thus, just git clone my repository and started editing and send me
> > patches (or github pull requests). Like:
> >
> >  $ git clone https://github.com/netoptimizer/prototype-kernel
> >  $ cd prototype-kernel/kernel/Documentation/
> >  $ make html
> >  $ firefox _build/html/index.html &
> >
> > This new documentation format combines the best of two worlds, pretty
> > online browser documentation with almost plain text files, and changes
> > being tracked via git commits [3] (and auto git hooks to generate the
> > readthedocs.org page). You got to love it! :-)
> >
> > --
> > Best regards,
> >   Jesper Dangaard Brouer
> >   MSc.CS, Principal Kernel Engineer at Red Hat
> >   Author of http://www.iptv-analyzer.org
> >   LinkedIn: http://www.linkedin.com/in/brouer
> >
> > [3] https://github.com/netoptimizer/prototype-kernel/commits/master  

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
