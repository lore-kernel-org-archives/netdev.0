From: Pedro Fortuna <pedro.fortuna@gmail.com>
Subject: Re: filtering packtes before OS takes care about them
Date: Sun, 6 Mar 2005 02:04:57 +0000
Message-ID: <db95d40c05030518043b50adb4@mail.gmail.com>
References: <09766A6E64A068419B362367800D50C0B58A17@moritz.faps.uni-erlangen.de>
	 <7bca1cb50502281209798e8a00@mail.gmail.com>
	 <db95d40c0503050608e1e98d9@mail.gmail.com>
	 <7bca1cb505030510586aeb96c1@mail.gmail.com>
	 <db95d40c050305113668c3ff07@mail.gmail.com>
	 <7bca1cb50503051729e3273d3@mail.gmail.com>
Reply-To: Pedro Fortuna <pedro.fortuna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Asim Shankar <asimshankar@gmail.com>
In-Reply-To: <7bca1cb50503051729e3273d3@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks for you help Asim :)

On Sat, 5 Mar 2005 19:29:34 -0600, Asim Shankar <asimshankar@gmail.com> wrote:
> Hi Pedro,
> 
> Yeah, it should be able to cover all outgoing packets as well.
> Basically, all struct packet_type{}s with the type field set to
> htons(ETH_P_ALL) are also called on outgoing packets (see
> dev_queue_xmit_nit() called by dev_queue_xmit() in net/core/dev.c)
> 
> Though as I mentioned earlier, I'm not sure if this will *always*
> happen (i.e., if outgoing packets *always* go through
> dev_queue_xmit()). Someone more knowledgeable may have to answer that.
> 
> Best of luck and let me know if you have any trouble,
> Regards,
> 
> -- Asim
> 
> On Sat, 5 Mar 2005 19:36:38 +0000, Pedro Fortuna
> <pedro.fortuna@gmail.com> wrote:
> > Hello Asim,
> > I tried again but this time in Fedora Core 3 (kernel 2.6.10-1.760_FC3)
> > and it went flawlessly.
> > I have a look into your example and also into the Phrack article you
> > mentioned and now I'm ready to begin some tests towards what I want to
> > implement.
> >
> > It's absolutly clear you can fetch (and modify) packets before they
> > are delivered to the TCP/IP stack with a custom packet_type function,
> > but is it also possible to intercept just before they are passed to
> > the network driver?
> >
> > Thanks,
> > -Pedro Fortuna
> >
> >
> > On Sat, 5 Mar 2005 12:58:23 -0600, Asim Shankar <asimshankar@gmail.com> wrote:
> > > > I wasnt able to compile your packet_type_test.c :
> > > > all I got was a huge list of errors
> > > > and warnings, and no .o compiled in the end.
> > >
> > > Can you send the specific errors you got?
> > > And is the kernel sources present in
> > > /lib/modules/`uname -r`/build?
> > >
> > > Regards,
> > >
> > > -- Asim
> > >
> >
>
