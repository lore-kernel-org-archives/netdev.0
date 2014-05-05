From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Mon, 5 May 2014 16:28:21 -0700
Message-ID: <20140505232821.GJ19657@tassilo.jf.intel.com>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
 <1399328773-6531-9-git-send-email-andi@firstfloor.org>
 <CAK6E8=cQ37-O=z6oxwhNZ+rog2VrLZQvjKW4sq+E97Yz-VNorQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	tom.zanussi@linux.intel.com
To: Yuchung Cheng <ycheng@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAK6E8=cQ37-O=z6oxwhNZ+rog2VrLZQvjKW4sq+E97Yz-VNorQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +config TCP_METRICS
> > +       bool "Report TCP metrics over netlink"
> > +       ---help---
> > +           Enable support in TCP to save host information between different
> > +          connections.
> Please add that "Certain TCP features such as active TCP Fast Open
> depends on this."

I added a select.

Also will fix the inaccurate help line.

-Andi
