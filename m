From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] decnet initialization race
Date: Thu, 15 Jan 2004 00:45:24 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115004524.4aec963a.davem@redhat.com>
References: <20040113105843.0d1351cb.shemminger@osdl.org>
	<20040113163631.1a9c1a59.davem@redhat.com>
	<20040114164045.06dd85f3.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040114164045.06dd85f3.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 14 Jan 2004 16:40:45 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Decnet exposes itself to proc and packets before it has finished initializing.
> This was always a race, but the notifier replay might expose it worse.

Applied.

Although, Arnaldo is not the listed DECNET maintainer last time I checked,
or is he being CC:'d for another reason? :-)
