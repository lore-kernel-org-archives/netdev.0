From: jamal <hadi@cyberus.ca>
Subject: Re: Intel and TOE in the news
Date: 21 Feb 2005 10:50:51 -0500
Message-ID: <1109001050.1076.6.camel@jzny.localdomain>
References: <20050220230713.GA62354@muc.de>
	 <200502210332.j1L3WkDD014744@guinness.s2io.com>
	 <20050221115006.GB87576@muc.de> <20050221132844.GU31837@postel.suug.ch>
	 <1108994621.1089.158.camel@jzny.localdomain>
	 <20050221141714.GV31837@postel.suug.ch>
	 <1108996313.1090.178.camel@jzny.localdomain>
	 <16922.89.271972.745365@robur.slu.se>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Andi Kleen <ak@muc.de>,
        Leonid Grossman <leonid.grossman@neterion.com>,
        "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        "'Alex Aizman'" <alex@neterion.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16922.89.271972.745365@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-02-21 at 10:38, Robert Olsson wrote:

>  Yes when queue length/batch increases you're risking to load the L2 
>  twice for the same skb. Which is the most expensive operation.... 

You are probably onto something here. I have to rerun with varying batch
sizes to see if this is true (although i did i think try with even 2 and
still saw performance degradation).

I will be revisiting these patches in about a month.

cheers,
jamal
