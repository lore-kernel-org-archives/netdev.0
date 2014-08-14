From: leroy christophe <christophe.leroy@c-s.fr>
Subject: Issue with commit 33c133cc7598e60976a phy: IRQ cannot be shared
Date: Thu, 14 Aug 2014 08:31:21 +0200
Message-ID: <53EC57B9.8080903@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Segei, Florian and David,

I have an hardware with two ethernet interfaces, and with the two PHYs 
inside the same component INTEL LXT973 which has only one interrupt.
I also have another hardware with two ethernet interfaces and two 
independant PHYs. But the two PHYs are wired to the same interrupt.
This is working perfectly up to Linux 3.12.

But since your commit, introduced in Linux 3.13, my interfaces don't 
work anymore as the second PHYs can't register IRQ.

Reading the commit log, I can't really understand the reason for the change.
Is it really worth it, and therefore how shall my case be handled ?

Christophe
