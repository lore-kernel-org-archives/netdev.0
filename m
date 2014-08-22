From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] br_multicast: Replace rcu_assign_pointer()
 with RCU_INIT_POINTER()
Date: Fri, 22 Aug 2014 12:28:31 -0700 (PDT)
Message-ID: <20140822.122831.451083152510385540.davem@davemloft.net>
References: <20140822130609.GA19576@ada>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, paulmck@linux.vnet.ibm.com,
	linux-kernel@vger.kernel.org
To: bernat.ada@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140822130609.GA19576@ada>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Date: Fri, 22 Aug 2014 16:06:09 +0300

> The use of "rcu_assign_pointer()" is NULLing out the pointer.
> According to RCU_INIT_POINTER()'s block comment:
> "1.   This use of RCU_INIT_POINTER() is NULLing out the pointer"
> it is better to use it instead of rcu_assign_pointer() because it has a
> smaller overhead.
 ...
> Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>

Applied.
