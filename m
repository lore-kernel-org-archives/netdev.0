From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH]  New Chapter on CodingStyle .
Date: Tue, 15 Aug 2017 16:55:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0056122@AcuExch.aculab.com>
References: <1502536998-5482-1-git-send-email-asd@marian1000.go.ro>
        <20170812085439.573c6c55@lwn.net>
        <063D6719AE5E284EB5DD2968C1650D6DD0055A0C@AcuExch.aculab.com>
 <20170815092030.7ec82ace@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Jonathan Corbet' <corbet@lwn.net>,
        Corcodel Marian <asd@marian1000.go.ro>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Realtek linux nic maintainers" <nic_swsd@realtek.com>
To: 'Stephen Hemminger' <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170815092030.7ec82ace@xeon-e3>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger
> Sent: 15 August 2017 17:21
> On Tue, 15 Aug 2017 10:42:39 +0000
> David Laight <David.Laight@ACULAB.COM> wrote:
> 
> > From: Jonathan Corbet
> > > Sent: 12 August 2017 15:55
> > ...
> > > > +		Chapter 20: Put values on initialisers without exception
> > > > +
> > > > +When declaring variables on functions must put values:
> > >
> > > Thanks for sending a patch for the kernel's documentation.
> > > Unfortunately, I can't accept this patch for a couple of reasons:
> > ...
> > > - The coding style document is there to describe the community's
> > >   standards for kernel code.  It is *not* a mechanism for imposing new
> > >   standards.  If you really think that the kernel community should adopt
> > >   this rule, you will need to argue for it on the mailing lists.  I will
> > >   say, though, that I do not expect that this effort would be successful.
> >
> > I'd even go as far as suggesting almost the opposite.
> > Declarations should only have initialisers if the value is constant.
> 
> Yup. This new rule sound like something taught to people in coding schools.
> But initializing everything defeats the compiler detection of uninitialized variables
> which is more useful for catching errors.

You'll also get:
Values being read the wrong side of locks.
Values being read early so requiring spilling to stack.

Next someone will be suggesting that all pointers should be checked
against NULL every time they are used.

	David
