From: James Morris <jmorris@intercode.com.au>
Subject: RE: [PATCH] LSM networking update: summary (0/5)
Date: Sat, 8 Feb 2003 10:10:44 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0302081002400.9462-100000@blackbird.intercode.com.au>
References: <7B2A7784F4B7F0409947481F3F3FEF8305CC9531@eammlex037.lmc.ericsson.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>,
   <linux-security-module@wirex.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Makan Pourzandi (LMC)" <Makan.Pourzandi@ericsson.ca>
In-Reply-To: <7B2A7784F4B7F0409947481F3F3FEF8305CC9531@eammlex037.lmc.ericsson.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 7 Feb 2003, Makan Pourzandi (LMC) wrote:

> Hi all,
> 
> My comments conecrn the (ip_decode_options, ip_encapsulate and
> ip_decapsulate) hooks. Even, if James has done much regarding this topic
> and I'm sure that he knows much more than me about it, I wanted to give
> my 2 cents on why we should keep these hooks in future releases.
> 

As mentioned during the last week, the current set of network hooks will
not directly support explicitly labeled networking.  It's not just the ip
hooks: you'd also need the skb and possibly other rejected hooks to make 
it useful.

Possibilities moving forward include reworking the design of the relevant
LSM frameork components so that they are acceptable to the network
maintainers in a future kernel release cycle, and investigating other
schemes such as implicit labeling (e.g. Ajaya Chitturi's work on the Flask
project).


- James
-- 
James Morris 
<jmorris@intercode.com.au>
