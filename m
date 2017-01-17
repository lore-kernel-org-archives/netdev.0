From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] audit: log 32-bit socketcalls
Date: Tue, 17 Jan 2017 11:21:36 -0500 (EST)
Message-ID: <20170117.112136.420514856297428019.davem@davemloft.net>
References: <299e5702e5876404ee2863cf95847f73cddb0a45.1484669022.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-audit@redhat.com
To: rgb@redhat.com
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <299e5702e5876404ee2863cf95847f73cddb0a45.1484669022.git.rgb@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

From: Richard Guy Briggs <rgb@redhat.com>
Date: Tue, 17 Jan 2017 11:07:15 -0500

> 32-bit socketcalls were not being logged by audit on x86_64 systems.
> Log them.  This is basically a duplicate of the call from
> net/socket.c:sys_socketcall(), but it addresses the impedance mismatch
> between 32-bit userspace process and 64-bit kernel audit.
> 
> See: https://github.com/linux-audit/audit-kernel/issues/14
> 
> Signed-off-by: Richard Guy Briggs <rgb@redhat.com>

Acked-by: David S. Miller <davem@davemloft.net>
