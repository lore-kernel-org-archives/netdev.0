From: "Alex Aizman" <alex@neterion.com>
Subject: RE: Intel and TOE in the news
Date: Mon, 21 Feb 2005 16:50:34 -0800
Message-ID: <200502220051.j1M0pDDD020128@guinness.s2io.com>
References: <421A45DD.3020805@pobox.com>
Reply-To: <alex@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Andi Kleen'" <ak@muc.de>,
        "'Leonid Grossman'" <leonid.grossman@neterion.com>,
        "'rick jones'" <rick.jones2@hp.com>, <netdev@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: <421A45DD.3020805@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Cookie" or no "cookie", demux in the OS or in the driver, does not matter
(well, it matters just a little bit :). The important think is to run MSI
handler on two (for starters) CPUs. Will check on it this week with 2.6.11.

Alex

> -----Original Message-----
> From: Jeff Garzik [mailto:jgarzik@pobox.com] 
> Sent: Monday, February 21, 2005 12:35 PM
> To: Alex Aizman
> Cc: 'Andi Kleen'; 'Leonid Grossman'; 'rick jones'; netdev@oss.sgi.com
> Subject: Re: Intel and TOE in the news
> 
> Alex Aizman wrote:
> > 2.6.11-rc4 MTHCA driver still does request_irq() just once for MSI
> > (note: MSI, not MSI-X). 
> 
> 
> I doubt that will change.
> 
> request_irq() is passed a "cookie" that enables your 
> interrupt handler. 
>   This cookie can be associated with more than one interrupt vector.
> 
> 	Jeff
> 
> 
> 
