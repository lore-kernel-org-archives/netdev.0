From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Intel and TOE in the news
Date: Mon, 21 Feb 2005 15:34:37 -0500
Message-ID: <421A45DD.3020805@pobox.com>
References: <000001c5184c$5599c890$0100a8c0@OFFICEONEATHOME>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Andi Kleen'" <ak@muc.de>,
        "'Leonid Grossman'" <leonid.grossman@neterion.com>,
        "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com
To: Alex Aizman <alex@neterion.com>
In-Reply-To: <000001c5184c$5599c890$0100a8c0@OFFICEONEATHOME>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alex Aizman wrote:
> 2.6.11-rc4 MTHCA driver still does request_irq() just once for MSI
> (note: MSI, not MSI-X). 


I doubt that will change.

request_irq() is passed a "cookie" that enables your interrupt handler. 
  This cookie can be associated with more than one interrupt vector.

	Jeff
