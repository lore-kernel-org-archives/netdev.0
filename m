From: Quantum Scientific <Info@Quantum-Sci.com>
Subject: Re: support of IPv6 by NFS
Date: Tue, 1 Mar 2005 07:44:37 -0600
Message-ID: <200503010744.38339.Info@Quantum-Sci.com>
References: <42243F8D.5030302@bull.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org
To: netdev@oss.sgi.com
In-Reply-To: <42243F8D.5030302@bull.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 01 March 2005 4:10, Gilles Quillard wrote:
> This works but this needs that the kernel has been compiled with IPv6, 
> which is not mandotary. A lot of people in the Linux community do not 
> have experience with IPv6 yet and are not ready to use it. So making it 
> mandatory for NFS, even in a pure IPv4 network, is not easy.

My experience is that IPV6 is extremely difficult to figure out how to set up 
securely, for the time being, due to lack of connection-sharing.  This little 
fact goes completely unmentioned in ALL of the HowTos.  Thank goodness for 
the USAGI project.

Also one must become an ip6tables expert in order to have a reasonably secure 
firewall, because ip6tables and 6tables are dead, and Shorewall does not 
support IPV6 security for some reason.  Another deterrant.

And 80% of potential users are behind a cable/DSL 4 NATting router.  There is 
no clarity that it is possible overcome this by either setting to DMZ, or 
hoping your cablemodem passes protos 41, 50 & 51.  Even some tunnel operators 
do not know this, so I had to figure it out myself.  There is no Linux 6to4 
UDP tunnelling app, but there should be, because this is such a common 
problem.  (As I understand, Teredo is Winduhs-only, and is not supported by 
most tunnel operators)

And frankly, most Linux users' only contact with IPV6 has been the DNS AAAA 
browser delay seemingly inherent in some distros.  Although I realize that 
all of us who run Linux are ostensibly uber-gurus, fact is this is a negative 
first experience for most, stemming from attempts by distros to encourage ppl 
to use it with an inoperative function, and without an obvious way to 
troubleshoot/repair.

These issues contradict assertions that IPV6 is beneficial and easy.  If I 
didn't have a strong motivation and lots of time, I would have chucked 
early-on.  Speaking the actual truth, not propaganda or spin, leads to 
understanding of the *real* world.

Carl Cook
