From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Thu, 19 Nov 2015 10:35:43 +0100
Message-ID: <564D97EF.70606@profihost.ag>
References: <564B3D35.50004@profihost.ag>
 <alpine.DEB.2.11.1511171936030.3761@nanos> <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos> <564CDE2F.8000201@profihost.ag>
 <1447880426.567228.443640225.76C879B7@webmail.messagingengine.com>
 <564CEBB6.5010608@profihost.ag>
 <1447881775.572008.443661801.3042D86D@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Florian Weimer <fweimer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447881775.572008.443661801.3042D86D@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Am 18.11.2015 um 22:22 schrieb Hannes Frederic Sowa:
> On Wed, Nov 18, 2015, at 22:20, Stefan Priebe wrote:
>> you mean just:
>> la /proc/$pid/fd
> 
> ls -l /proc/pid/fd/
> 
> the numbers in brackets in return from readlink are the inode numbers.
> 
>> and
>>
>> cat /proc/net/netlink
> 
> Exactly, last row is the inode number.

It has stopped locking since i've set:

net.ipv6.conf.all.disable_ipv6=1

Stefan
