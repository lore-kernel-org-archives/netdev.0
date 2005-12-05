From: Al Boldi <a1426z@gawab.com>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Mon, 5 Dec 2005 23:48:55 +0300
Message-ID: <200512052348.55603.a1426z@gawab.com>
References: <200512022253.19029.a1426z@gawab.com> <4391E4FC.1040200@candelatech.com> <20051205140057.GC24764@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	Ben Greear <greearb@candelatech.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20051205140057.GC24764@tuxdriver.com>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> > Al Boldi wrote:
> > >Here specifically, ip/ifconfig is implemented upside-down requiring a
> > >link/dev to exist for an address to be defined, in effect containing
> > > layer 3 inside layer 2, when an address should be allowed to be
> > > defined w/o a link/dev much like an app is allowed to be defined w/o
> > > an address.
> >
> I think Al B.'s idea merits some consideration.  I definitely think
> we blur the distinctions between L2 and L3 a bit too much in places.
>
> Of course, patches would be helpful...

I am envisaging a complete decoupling of the current implementation to 
achieve OSI compliance.  And that's not for the sake of OSI but for the sake 
of scalability.

This means that it should be possible define a layer 3 network architecture 
completely independent of a layer 2 link architecture.

This also means that we are free to choose means other than a layer 2 link to 
fulfill layer 3 requests and vice/versa.

And it may open the door to many other things...  due to scalability.

Thanks!

--
Al

