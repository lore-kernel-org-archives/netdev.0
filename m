From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix NAPI race
Date: Tue, 29 Jul 2003 22:22:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030729222242.4ba89d51.davem@redhat.com>
References: <20030729060509.GB13227@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, miltonm@bga.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20030729060509.GB13227@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 29 Jul 2003 16:05:09 +1000
Anton Blanchard <anton@samba.org> wrote:

> Milton and I debugged an oops where we did list_del on a poisoned list
> entry. It turns out there is nothing to order between list_del on
> poll_list and the clear_bit that serialises list_add.

Applied, thanks Anton.
