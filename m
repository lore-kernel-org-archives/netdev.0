From: "David S. Miller" <davem@redhat.com>
Subject: Re: Bug? ARP with wrong src IP address
Date: Thu, 24 Jul 2003 11:37:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030724113731.73e9bbf6.davem@redhat.com>
References: <Pine.LNX.4.44.0307241922270.10460-100000@l>
	<200307241836060226.006FACEB@192.168.128.16>
	<200307242011420101.00BC642D@192.168.128.16>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: carlosev@newipnet.com, ja@ssi.bg, bdschuym@pandora.be, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Carlos Velasco" <carlosev@newipnet.com>
In-Reply-To: <200307242011420101.00BC642D@192.168.128.16>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 24 Jul 2003 20:11:42 +0200
"Carlos Velasco" <carlosev@newipnet.com> wrote:

> Tested these platforms:
> 
> Solaris 8 -> sends src IP address of INTERFACE
> Cisco -> sends src IP address of INTERFACE
> Windows 2000, XP -> sends src IP address of INTERFACE
> Linux 2.6.0-pre1, 2.4.20, 2.4.21 -> sends src IP address of LOOPBACK
> 
> Question: _What would be the implications of applying my patch or similar to do linux behave like other OS?

You'll break things for people who depend upon the
way Linux currently behaves.
