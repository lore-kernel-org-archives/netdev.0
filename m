From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: Problems getting a stable 100 megabit connection with linksys etherfast switch
Date: Tue, 2 Mar 2004 00:01:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403020001.48026.vda@port.imtp.ilyichevsk.odessa.ua>
References: <20040229212053.M47845@spots.ca>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "john" <johnp@marine-boy.nu>, Andrewm@uow.edu.au, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
In-Reply-To: <20040229212053.M47845@spots.ca>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 29 February 2004 23:30, john wrote:
> Hi,
>
> I am having problems getting a stable connection with my linux machines
> when trying to connect them at 100 megabit speeds to a linksys etherfast
> switch.
>
>
> I have attached some diagnostic outputs for your review.  I hope that
> someone can help me with this problem.
>
> I believe using a managed switch will solve the problem, but I don't want
> to have to spend $1000.00 to fix this problem, when I should be able to
> obtain a stable connection with the equipment I am currently using.

Try half duplex. You seldom do lots of xfers in both directions at once,
so half duplex is not a big loss.

Use tcpdump to see what's going on on the wire.
--
vda
