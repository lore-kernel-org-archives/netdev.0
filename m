From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][IPV6] fixed authentication error with TCP
Date: Mon, 18 Aug 2003 00:45:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818004522.458a97b9.davem@redhat.com>
References: <200308172329.DAA14889@dub.inr.ac.ru>
	<Pine.LNX.4.44.0308181029560.18400-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, kazunori@miyazawa.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org, latten@austin.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0308181029560.18400-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 10:45:41 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> The attached patch reverts to the old ip6_dst_lookup() interface and and
> makes tcp_ipv6.c use that instead.
> 
> As an added bonus neither tcp_v6_connect() nor udpv6_connect() needs to do
> source address selection anymore, since ip6_dst_lookup() already does this
> for them.

Thanks a lot for doing this work, I'll review and apply
your patch.

I was about to code this up myself :)
