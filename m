From: Elliott Mitchell <ehem@m5p.com>
Subject: Re: (usagi-users 03226) Re: support of IPv6 by NFS
Date: Tue, 1 Mar 2005 13:37:52 -0800 (PST)
Message-ID: <200503012137.j21LbqmL005962@m5p.com>
References: <200503011256.25282.Info@quantum-sci.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jeroen Massar <jeroen@unfix.org>
In-Reply-To: <200503011256.25282.Info@quantum-sci.com>
To: usagi-users@linux-ipv6.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>From: Quantum Scientific <Info@quantum-sci.com>
> On Tuesday 01 March 2005 9:08, Jeroen Massar wrote:
> > On Tue, 2005-03-01 at 07:44 -0600, Quantum Scientific wrote: 
> > >On Tuesday 01 March 2005 4:10, Gilles Quillard wrote:
> > >> This works but this needs that the kernel has been compiled with IPv6, 
> > >> which is not mandotary. A lot of people in the Linux community do not 
> > >> have experience with IPv6 yet and are not ready to use it. So making it 
> > >> mandatory for NFS, even in a pure IPv4 network, is not easy.
> > >
> > >My experience is that IPV6 is extremely difficult to figure out how to set 
> up 
> > >securely, for the time being, due to lack of connection-sharing.
> > 
> > NAT is not a firewall. Get that into your brain.
> 
> Jeroen, was this addressed to me, or to Giles?  Never mind, it doesn't matter;  your 
> words show that you are an uneducated man.

Though I was planning to be more polite, I was going to write a similar
message. If you're depending on a firewall as a main defense, you're
already dead. If you wish your hosts to be secure, they MUST be secure
even if they didn't have a firewall!

The already mentioned approach works quite well. Filter packets with
only the SYN bit set, no incoming connections will work, outgoing
connections will be unaffected. No state needed. Though important for a
firewall, stateful filtering isn't a critical feature to state the IPv6
stack is working.


-- 
(\___(\___(\______          --=> 8-) EHM <=--          ______/)___/)___/)
 \   (    |         EHeM@gremlin.m5p.com PGP 8881EF59         |    )   /
  \_  \   |  _____  -O #include <stddisclaimer.h> O-   _____  |   /  _/
    \___\_|_/82 04 A1 3C C7 B1 37 2A*E3 6E 84 DA 97 4C 40 E6\_|_/___/
