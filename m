From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/bridge: Use RCU_INIT_POINTER(x,
	NULL) in br_vlan.c
Date: Tue, 25 Mar 2014 21:19:23 -0400 (EDT)
Message-ID: <20140325.211923.1366926482436380447.davem@davemloft.net>
References: <1395601873-12447-1-git-send-email-monamagarwal123@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: monamagarwal123@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1395601873-12447-1-git-send-email-monamagarwal123@gmail.com>
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

From: Monam Agarwal <monamagarwal123@gmail.com>
Date: Mon, 24 Mar 2014 00:41:13 +0530

> This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)
> 
> The rcu_assign_pointer() ensures that the initialization of a structure       
> is carried out before storing a pointer to that structure. 
> And in the case of the NULL pointer, there is no structure to initialize. 
> So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)
> 
> Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>

Applied.
