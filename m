From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH][net-next] rxrpc: remove redundant proc_remove call
Date: Fri, 02 Jun 2017 22:37:44 +0100
Message-ID: <21413.1496439464@warthog.procyon.org.uk>
References: <20170602152227.3626-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, "David S . Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170602152227.3626-1-colin.king@canonical.com>
Content-ID: <21412.1496439464.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin King <colin.king@canonical.com> wrote:

> From: Colin Ian King <colin.king@canonical.com>
> 
> The proc_remove call is dead code as it occurs after a return and
> hence can never be called. Remove it.
> 
> Detected by CoverityScan, CID#1437743 ("Logically dead code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: David Howells <dhowells@redhat.com>
