From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: Fix tbf_reset
Date: Tue, 18 Nov 2003 17:25:27 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118172527.5c2c0a1f.davem@redhat.com>
References: <3FB39990.3000205@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <3FB39990.3000205@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 13 Nov 2003 15:47:44 +0100
Patrick McHardy <kaber@trash.net> wrote:

> This patch fixes TBF purging an unused queue in tbf_reset instead
> of resetting q.qlen. I haven't checked the history, but it looks
> like this place was forgotten when making TBF classful.

Yes, the bug was introduced when adding inner-qdisc attaching
support to TBF.

Thanks for tracking this down Patrick, patch applied.
