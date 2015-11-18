From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Wed, 18 Nov 2015 22:22:55 +0100
Message-ID: <1447881775.572008.443661801.3042D86D@webmail.messagingengine.com>
References: <564B3D35.50004@profihost.ag> <alpine.DEB.2.11.1511171936030.3761@nanos>
 <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos>
 <564CDE2F.8000201@profihost.ag>
 <1447880426.567228.443640225.76C879B7@webmail.messagingengine.com>
 <564CEBB6.5010608@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stefan Priebe <s.priebe@profihost.ag>,
	Thomas Gleixner <tglx@linutronix.de>,
	Florian Weimer <fweimer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564CEBB6.5010608@profihost.ag>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 18, 2015, at 22:20, Stefan Priebe wrote:
> you mean just:
> la /proc/$pid/fd

ls -l /proc/pid/fd/

the numbers in brackets in return from readlink are the inode numbers.

> and
> 
> cat /proc/net/netlink

Exactly, last row is the inode number.

Bye,
Hannes
