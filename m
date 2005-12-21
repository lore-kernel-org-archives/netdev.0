From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] handle module ref count on sysctl tables.
Date: Wed, 21 Dec 2005 19:42:02 +0100
Message-ID: <1135190522.3456.72.camel@laptopd505.fenrus.org>
References: <20051221103520.258ced08@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ftp.linux.org.uk>, Andrew Morton <akpm@osdl.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751159AbVLUSmI@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20051221103520.258ced08@dxpl.pdx.osdl.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2005-12-21 at 10:35 -0800, Stephen Hemminger wrote:
> 
> This patch fixes that by maintaining source compatibility via macro.
> I am sure someone already thought of this, it just doesn't appear to
> have made it in yet.

isn't it more consistent to give the sysctl table itself an .owner
field?
