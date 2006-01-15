From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: wireless: recap of current issues (other issues)
Date: Sun, 15 Jan 2006 09:23:29 -0200
Message-ID: <39e6f6c70601150323v5f2764d1x4bc10d90bf2104df@mail.gmail.com>
References: <20060113213237.GH16166@tuxdriver.com>
	 <20060113222408.GM16166@tuxdriver.com> <43C97693.7000109@pobox.com>
	 <20060114.175140.07007614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: jgarzik@pobox.com, linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751898AbWAOLXb@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060114.175140.07007614.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/14/06, David S. Miller <davem@davemloft.net> wrote:
> From: Jeff Garzik <jgarzik@pobox.com>
> Date: Sat, 14 Jan 2006 17:09:23 -0500
>
> > A big open issue:  should you fake ethernet, or represent 802.11
> > natively throughout the rest of the net stack?
> >
> > The former causes various and sundry hacks, and the latter requires that
> > you touch a bunch of non-802.11 code to make it aware of a new frame class.
>
> The former, most importantly, can cause the packet to get copied.
> Actually, this depends upon how you implement things and when the
> header change occurs.
>
> My vote is for making the whole of the networking 802.11 frame class
> aware.

Agreed :-)

- Arnaldo
