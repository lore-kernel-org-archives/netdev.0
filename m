From: "David S. Miller" <davem@redhat.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Thu, 11 Sep 2003 16:29:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911162911.589211eb.davem@redhat.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, scott.feldman@intel.com, netdev@oss.sgi.com,
   ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F6103BB.5030706@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 11 Sep 2003 16:22:35 -0700
Ben Greear <greearb@candelatech.com> wrote:

> David S. Miller wrote:
> > So, again, dampen the per-socket send queue sizes.
> 
> That's just a band-aid to cover up the flaw with the lack
> of queue-pressure feedback to the higher stacks, as would be increasing the
> TxDescriptors for that matter.

The whole point of the various packet scheduler algorithms
are foregone if we're just going to queue up and send the
crap again.
