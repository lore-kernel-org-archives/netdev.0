From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 18:23:38 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030610.182338.41657455.davem@redhat.com>
References: <3EE67D2D.80608@candelatech.com>
	<20030610.180120.71112140.davem@redhat.com>
	<Pine.LNX.4.51.0306102115210.18076@ns.istop.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, Robert.Olsson@data.slu.se,
	hadi@shell.cyberus.ca, xerox@foonet.net, sim@netnation.com,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: ralph+d@istop.com, ralph@istop.com
In-Reply-To: <Pine.LNX.4.51.0306102115210.18076@ns.istop.com>
List-Id: netdev.vger.kernel.org

   From: Ralph Doncaster <ralph@istop.com>
   Date: Tue, 10 Jun 2003 21:17:28 -0400 (EDT)

   Aren't the read_lock_irqsave and restore expensive?

If x86 has an inefficient implementation, well... :-)

This can be done without locks, nobody has done the x86 implementation
of that that's all.  I think the x86_64 folks did a lockless version,
I know I did for sparc64 :)

