From: Ralph Doncaster <ralph@istop.com>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 20:56:43 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.51.0306092052380.18082@ns.istop.com>
References: <20030609082718.GG20613@netnation.com> <004f01c32ebe$b4bd88d0$4a00000a@badass>
 <20030609221911.GF11509@netnation.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: CIT/Paul <xerox@foonet.net>,
	"'David S. Miller'" <davem@redhat.com>,
	"hadi@shell.cyberus.ca" <hadi@shell.cyberus.ca>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20030609221911.GF11509@netnation.com>
List-Id: netdev.vger.kernel.org

On Mon, 9 Jun 2003, Simon Kirby wrote:

> [sroot@r2:/root]# while (1)
> [sroot@r2:(while)]# sleep 1
> [sroot@r2:(while)]# ip -o route show cache | wc -l
> [sroot@r2:(while)]# end

I considered doing the same test on my box, but I don't have enough juice
left to do it every second:
root@tor-router# time ip -o route show cache | wc -l
  15023
real    0m1.563s
user    0m0.380s
sys     0m1.180s

So instead...

root@tor-router# while (true); do sleep 5; ip -o route show cache | wc -l;
done
  12630
  15659
  17951
  20733
   8875
   9282
  11913
   4216
   9437
  11973
  14503
  17088

-Ralph

