From: jamal <hadi@cyberus.ca>
Subject: Re: TX performance of Intel 82546
Date: 15 Sep 2004 09:49:51 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095256191.1043.17.camel@jzny.localdomain>
References: <20040915081439.GA27038@sunbeam.de.gnumonks.org>
	 <414808F3.70104@draigBrady.com>  <16712.14153.683690.710955@robur.slu.se>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: P@draigBrady.com, Harald Welte <laforge@netfilter.org>,
        Linux NICS <linux.nics@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16712.14153.683690.710955@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-09-15 at 08:36, Robert Olsson wrote:

>  > In my experience anything around 750Kpps is a PCI limitation,
>  > specifically PCI bus arbitration latency. Note the clock speed of
>  > the control signal used for bus arbitration has not increased
>  > in proportion to the PCI data clock speed.
>=20
>  Yes data from an Opteron @ 1.6 GHz w. e1000 82546EB 64 byte pkts.
>=20
>  133 MHz 830 pps
>  100 MHz 721 pps
>   66 MHz 561 pps
>=20
>  So higher bus bandwidth could increase the small packet rate.

Nice data.
BTW, is this per interface? i thought i have seen numbers in the range
of 1.3Mpps from you.

>  So is there a difference in PCI-tuning BSD versus Linux?=20

As far as i could tell they batch transmit (mostly because of the way
mbufs are structured really).=20

>  And even more general can we measure the maximum numbers
>  of transactions on a PCI-bus?

You would need speacilized hardware for this i think.

>  Chip should be able to transfer 64 packets in single burst I don't now
>  how set/verify this.

What P=E1draig.posted in regards to the MMRBC register is actually
enlightening. I kept thinking about it after i sent my last email.
If indeed the overhead is incured in the setup(all fingers in my test
setups point fingers at this) then increasing the burst size should show
improvements.

cheers,
jamal
