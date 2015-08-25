From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] route: put lwstate before freeing dst to avoid use after
 free
Date: Tue, 25 Aug 2015 20:28:40 +0200
Message-ID: <20150825182840.GL3707@pox.localdomain>
References: <1440527114-12746-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jbenc@redhat.com, roopa@cumulusnetworks.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1440527114-12746-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/25/15 at 02:25pm, Sasha Levin wrote:
> Commit 61adedf3 ("route: move lwtunnel state to dst_entry") is trying to
> release lwstate after getting rid of dst, which causes a use-after-free
> trying to access dst->lwstate.
> 
> Fixes: 61adedf3 ("route: move lwtunnel state to dst_entry")
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
