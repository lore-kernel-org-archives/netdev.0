From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] netem - enhancement
Date: Wed, 18 Aug 2004 14:16:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040818141600.1fd67e91.davem@redhat.com>
References: <20040811123103.620c2a36@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040811123103.620c2a36@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Aug 2004 12:31:03 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This still needs more testing to go into the mainstream but here is the
> updated version of netem.  It adds:
>   * distribution table (if any) loaded as part of the configuration
>   * random packet duplication
>   * correlated random number's for loss, jitter, duplication
>   * changing netem parameters doesn't wipe out underlying qdisc
>   * better random number generator - simple net_random just isn't good enough
> 
> Also more complete comments and attribution.

I guess you will soon post an updated version
that makes use of the newer net_getrandom() stuff?
