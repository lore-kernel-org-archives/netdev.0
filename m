From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] (1/4) netem - update API for new features
Date: Wed, 25 Aug 2004 16:25:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040825162513.52bdeadf.davem@redhat.com>
References: <20040825105339.30210e84@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040825105339.30210e84@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Aug 2004 10:53:39 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Extend netem options to support new features.

This breaks all existing tc binaries.  We have to stop
doing this.

Yes, you can extend the structure, but when you do that you
have to teach functions like netem_change() how to cope
with the old structure layout.
