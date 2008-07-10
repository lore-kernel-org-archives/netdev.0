From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 10 Jul 2008 23:21:37 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0807102314440.14321@blackhole.kfki.hu>
References: <47EA0DAB.7080205@securenet.de> <200807071518.10912.thomas.jarosch@intra2net.com>
 <Pine.LNX.4.64.0807101457380.13027@blackhole.kfki.hu>
 <200807101612.59380.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200807101612.59380.thomas.jarosch@intra2net.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 Jul 2008, Thomas Jarosch wrote:

> On Thursday, 10. July 2008 15:17:53 you wrote:
> > It looks as the smtp server receives the packets slowly and it's just
> > behind the client. There's no more packet to/from port 53132 in the
> > tcpdump.
> 
> Thanks for looking into this, Jozsef. If you take a look at the timing 
> information, the connection was already running ~270 seconds without real 
> data transfer. The mailserver then aborts the SMTP connection with the error 
> msg: "421 mailbackup.webpage.t-com.de Lost connection to [217.85.147.6]"
> Only after that the port is "changed" to the wrong one.
>
> The time ranges between the retransmissions seem
> to really go downhill after the first retransmission.
> 
> The linux box is connected via a mostly idle 2 mbit SDSL line, the mailserver
> is located at the provider. So theoretically this shouldn't be slow at all.
> This is also proved as 2.6.23.17 works without trouble.

You did not mention the type of your driver. Isn't there some changes in 
the driver code between 2.6.23.17 and 2.6.24 which could cause such 
stallings?

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
