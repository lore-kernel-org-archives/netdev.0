From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Poll about irqsafe_cpu_add and others
Date: Thu, 17 Mar 2011 15:23:54 +0100
Message-ID: <1300371834.6315.93.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

irqsafe_cpu_{dec|inc} are used in network stack since 2.6.37 (commit
29b4433d991c88), and I would like to use irqsafe_cpu_add() in netfilter
fast path too, and SNMP counters eventually (to lower ram needs by 50%)

Initial support of irqsafe_ was given by Christoph in 2.6.34

It seems only x86 arch is using a native and efficient implementation.

Others use irqsafe_cpu_generic_to_op() and its pair of
local_irq_save() / local_irq_restore()

Which other arches could use a native implementation ?

What about defining a HAVE_FAST_IRQSAFE_ADD ?

Thanks
