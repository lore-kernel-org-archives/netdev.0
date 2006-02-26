From: "Stephen Evanchik" <evanchsa@gmail.com>
Subject: Re: [Announce] Intel PRO/Wireless 3945ABG Network Connection
Date: Sat, 25 Feb 2006 20:09:38 -0500
Message-ID: <a71293c20602251709p32a454cch746a5488a94d0e75@mail.gmail.com>
References: <43FF88E6.6020603@linux.intel.com>
	 <200602250549.47547.gene.heskett@verizon.net>
	 <20060225105340.GA23643@infradead.org>
	 <200602250619.04567.gene.heskett@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Christoph Hellwig" <hch@infradead.org>,
	"James Ketrenos" <jketreno@linux.intel.com>,
	NetDev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751012AbWBZBJj@vger.kernel.org>
To: gene.heskett@verizononline.net
In-Reply-To: <200602250619.04567.gene.heskett@verizon.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/25/06, Gene Heskett <gene.heskett@verizon.net> wrote:

> that apply to all". These rules go back to about the time of when they
> outlawed any transmit tunability in CB radios in the later 70's, so its
> not a new item by any means as its just an extension of that edict to
> cover this newer technology. The fact that it effectively put a stop to
> conference call type use of single sideband because no 2 radios were on
> the same, now non-adjustable frequency was an undesirable thing, but
> thats the breaks.  I might try and look it up after I've had some zz's,
> as I just came from doing transmitter maintainance overnight.

I'm not really sure what you are describing but you probably want to
reference CFR Title 47 Telecommunications [1]. Particularly
interesting is 15.202 "Certified operating frequency range." which
says in part:

"... Master devices marketed within the United States must be
limited to operation on permissible part 15 frequencies. Client devices
that can also act as master devices must meet the requirements of a
master device. ..."

Also there is a general prohibition on "harmful interference" in 15.5
which says in part:

"(b) Operation of an intentional, unintentional, or incidental
radiator is subject to the conditions that no harmful interference is
caused and that interference must be accepted that may be caused by the
operation of an authorized radio station, by another intentional or
unintentional radiator, by industrial, scientific and medical (ISM)
equipment, or by an incidental radiator. .."

I am going to guess that these two excerpts provide strong evidence
that Intel has to keep their radios from being modified accidentally
or purposefully. I also suspect that they only have to make it
difficult for an end user and not a technologist. So the well defined
interface between the closed source binary only userspace daemon and
the open source kernel driver could be reverse engineered and an
unencumbered replacement created.

I am definitely not a lawyer and this stuff is always subject to
someone making an argument in court.


Stephen

[1] http://www.access.gpo.gov/nara/cfr/waisidx_05/47cfr15_05.html
