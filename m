From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.6 PATCH] Fix IPVS sync state check
Date: Mon, 13 Oct 2003 12:25:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031013122540.0446f173.davem@redhat.com>
References: <Pine.LNX.4.44.0310132306490.1216-200000@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ja@ssi.bg
Return-path: <netdev-bounce@oss.sgi.com>
To: Wensong Zhang <wensong@linux-vs.org>
In-Reply-To: <Pine.LNX.4.44.0310132306490.1216-200000@penguin.linux-vs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Oct 2003 23:15:26 +0800 (CST)
Wensong Zhang <wensong@linux-vs.org> wrote:

> Here is a one-line fix in the sync state check for the connection to be
> synchronized. Since both the primay and the backup IPVS sync daemon can be
> started in a box at a time now, we must check if the MASTER bit is set in
> the sync state exactly.
> 
> Please check and apply it.

Looks good, applied.  Thanks.

BTW, on the 2.4.x side the IPVS code still has the NF_DROP return
which Julian changed in the 2.6.x version of the IPVS code.  Maybe
this 2.6.x NF_DROP change needs to be propagated into the 2.4.x code?
