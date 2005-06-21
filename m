From: Simon Kelley <simon@thekelleys.org.uk>
Subject: Re: ipw2100: firmware problem
Date: Tue, 21 Jun 2005 09:46:10 +0100
Message-ID: <42B7D3D2.8010606@thekelleys.org.uk>
References: <20050608142310.GA2339@elf.ucw.cz>	<200506081744.20687.vda@ilport.com.ua>	<20050608145653.GA8844@dwarf.suse.cz>	<42B7C4D0.9070809@thekelleys.org.uk> <20050621102921.5a8c953a@alfa.nmskb.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jirka Bohac <jbohac@suse.cz>, Denis Vlasenko <vda@ilport.com.ua>,
        Pavel Machek <pavel@ucw.cz>, Jeff Garzik <jgarzik@pobox.com>,
        Netdev list <netdev@oss.sgi.com>,
        kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Feyd <feyd@nmskb.cz>
In-Reply-To: <20050621102921.5a8c953a@alfa.nmskb.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Feyd wrote:
> On Tue, 21 Jun 2005 08:42:08 +0100
> Simon Kelley <simon@thekelleys.org.uk> wrote:
> 
> 
>>The atmel driver includes a small firmware stub which does nothing but 
>>determine the MAC address, to solve this problem. This is compiled into 
> 
> 
> Does it power-down the card after reading the MAC?
> 

Yes, it loads the special firmware, runs it to get the MAC, and then 
returns the card to quiesent state, ready for the real firmware load 
which happens at device open time.

Cheers,

Simon.
