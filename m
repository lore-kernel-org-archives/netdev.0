From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 31 Jul 2008 10:39:56 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807311035350.4551@wrl-59.cs.helsinki.fi>
References: <47EA0DAB.7080205@securenet.de> <200807111633.42514.thomas.jarosch@intra2net.com>
 <200807151347.23598.thomas.jarosch@intra2net.com>
 <200807151810.45942.thomas.jarosch@intra2net.com> <20080715153045.12efaea4@tux>
 <55u7m5-i63.ln1@tux.abusar.org.br>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1905046102-1217489996=:4551"
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <55u7m5-i63.ln1@tux.abusar.org.br>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1905046102-1217489996=:4551
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 31 Jul 2008, Dâniel Fraga wrote:

> On Tue, 15 Jul 2008 15:30:45 -0300
> Dâniel Fraga <fragabr@gmail.com> wrote:
> 
> > 	I'm using kernel 2.6.26 and the problem has gone. No stalled
> > connections anymore. The problem was with 2.6.25 kernel only.
> 	
> 	Sorry, I was wrong. In 2.6.26 the problem remains.
> 
> 	Everyday my connection stalls to my NNTP server using 2.6.26
> too. Before I just used a "nmap -sS server" and the connection would
> come back, but now it doesn't work.

Tcpdumping it would help some... :-) Can you try the suggested patch if it 
changes any (though would I have a tcpdump showing the problem, I could 
probably tell right away if the patch would help or not, and also come up 
with something else if necessary :-)):

  http://marc.info/?l=linux-netdev&m=121699478406378&w=2



-- 
 i.
---696208474-1905046102-1217489996=:4551--
