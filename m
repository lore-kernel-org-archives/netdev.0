From: "David S. Miller" <davem@redhat.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Mon, 15 Sep 2003 16:15:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915161546.6e685195.davem@redhat.com>
References: <Pine.LNX.4.44.0309081953510.1261-100000@localhost.localdomain>
	<3F60CA6D.9090503@pobox.com>
	<3F60D0F3.8080006@candelatech.com>
	<20030911131219.0ab8dfdd.davem@redhat.com>
	<3F60DDCC.5020906@candelatech.com>
	<20030911140746.4f0384a1.davem@redhat.com>
	<3F60E947.4090005@candelatech.com>
	<20030911142906.74d9dfe5.davem@redhat.com>
	<3F60F3F7.6090203@candelatech.com>
	<20030911160252.6cd6c07d.davem@redhat.com>
	<3F6103BB.5030706@candelatech.com>
	<1063330463.1028.8.camel@jzny.localdomain>
	<20030912204947.5267e3aa.davem@redhat.com>
	<16227.1284.893748.365713@robur.slu.se>
	<1063627928.1075.66.camel@jzny.localdomain>
	<16229.49798.506152.832140@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Robert.Olsson@data.slu.se, greearb@candelatech.com,
   jgarzik@pobox.com, scott.feldman@intel.com, netdev@oss.sgi.com,
   ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16229.49798.506152.832140@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Sep 2003 15:45:42 +0200
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

>  > The current default 3 band queue is good enough, the only challenge
>  > being noone sees stats for it. I have a patch for the kernel at:
>  > http://www.cyberus.ca/~hadi/patches/restore.pfifo.kernel
>  > and for tc at:
>  > http://www.cyberus.ca/~hadi/patches/restore.pfifo.tc
>  
>  Yes. 
>  I've missed this. Our lazy work-around for the missing stats is to install 
>  pfifo qdisc as said. IMO it should be included.

I've included Jamal's pfifo_fast statistic patch, and the
change to increase ethernet's tx_queue_len to 1000 in all
of my trees.

Thanks.
