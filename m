From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: Submission for S2io 10GbE driver
Date: Mon, 16 Feb 2004 15:53:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <000201c3f4e8$0bc7cf60$7410100a@S2IOtech.com>
References: <40314058.2000307@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <raghavendra.koushik@s2io.com>,
        "'ravinandan arakali'" <ravinandan.arakali@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: <40314058.2000307@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> http://pciids.sourceforge.net/
>The file drivers/pci/pci.ids is only associated with /proc/pci strings,

>and I'm trying to deprecate it :)

Done, thanks for the pointer!


>> 2. The card fully supports Ethernet and TCP header separation in 
>> hardware (so called receive 3-buffer mode). The mode may have some 
>> performance advantages but so far we did not implement the mode in 
>> Linux since it seems that Linux stack can't handle the fragmented 
>> buffers in the receive path. Is this a correct assumption, does 
>> receive buffer has to be continuous?

>In theory, the skb can be fragmented.  I'm not as much as an expert in 
>the ipv4/tcp/socket levels of the net stack, but I don't recall any 
>place that yet supports skb frags on receive?

>I think that's likely an area that would need some minor 
>adjustments/additions in the upstream kernels, but not major surgery, 
>since the skb already supports creating, noticing, and freeing frags.

>	Jeff


I think it will be a good idea to have full support for skb frags in
general, and not just for our product.

Please let me know if there is a consensus (and hopefully a timeframe
:-) for this; 
We volunteer to implement the mode in our driver and test the solution.

Leonid
