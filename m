From: "David S. Miller" <davem@redhat.com>
Subject: Re: [UPDATED PATCH]: Adjust qlen when grafting in multiple qdiscs
Date: Tue, 18 Nov 2003 17:19:52 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118171952.7c990eb3.davem@redhat.com>
References: <3FB3996A.6080008@trash.net>
	<1069076786.1075.19.camel@jzny.localdomain>
	<3FB8DDE0.1070105@trash.net>
	<1069081153.1022.20.camel@jzny.localdomain>
	<3FB8F3BF.6050509@trash.net>
	<1069090210.1022.64.camel@jzny.localdomain>
	<20031117163834.V1330@almesberger.net>
	<3FB96930.9020300@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <3FB96930.9020300@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 18 Nov 2003 01:34:56 +0100
Patrick McHardy <kaber@trash.net> wrote:

> this patch fixes multiple qdiscs to adjust sch->q.qlen when
> replacing a non-empty inner qdisc. The only change to the
> first patch is in dsmark_graft: this patch directly sets
> sch->q.qlen to 0 instead of subtracting the length of the
> inner qdisc.

Applied, thanks Patrick.

I'll stick this into my 2.4.24-pre1 queue as well.

Thanks again.
