From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] enhanced version of net_random()
Date: Fri, 20 Aug 2004 11:47:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040820114710.39023b20.davem@redhat.com>
References: <20040812104835.3b179f5a@dell_ss3.pdx.osdl.net>
	<20040820175952.GI5806@certainkey.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, alan@lxorguk.ukuu.org.uk, tytso@mit.edu,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean-Luc Cooke <jlcooke@certainkey.com>
In-Reply-To: <20040820175952.GI5806@certainkey.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 20 Aug 2004 13:59:52 -0400
Jean-Luc Cooke <jlcooke@certainkey.com> wrote:

> Is there a reason why get_random_bytes() is unsuitable?
> 
> Keeping the number of PRNGs in the kernel to a minimum should a goal we can
> all share.

Too expensive, this routine will get called potentially multiple times
per packet.
