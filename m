From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Intel and TOE in the news
Date: Mon, 21 Feb 2005 16:38:01 +0100
Message-ID: <16922.89.271972.745365@robur.slu.se>
References: <20050220230713.GA62354@muc.de>
	<200502210332.j1L3WkDD014744@guinness.s2io.com>
	<20050221115006.GB87576@muc.de>
	<20050221132844.GU31837@postel.suug.ch>
	<1108994621.1089.158.camel@jzny.localdomain>
	<20050221141714.GV31837@postel.suug.ch>
	<1108996313.1090.178.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Andi Kleen <ak@muc.de>,
        Leonid Grossman <leonid.grossman@neterion.com>,
        "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        "'Alex Aizman'" <alex@neterion.com>
To: hadi@cyberus.ca
In-Reply-To: <1108996313.1090.178.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


jamal writes:

 > Infact performance goes down when you batch in some cases depending on
 > the hardware used. My investigation shows that if you have a fast CPU
 > and a fast bus, theres always only one packet in flight within the
 > stack. Batching by definition requires more than one packet.

 Hello!

 Yes when queue length/batch increases you're risking to load the L2 
 twice for the same skb. Which is the most expensive operation.... 
 Forwarding profiles show most functions where cache misses occur.

					--ro
