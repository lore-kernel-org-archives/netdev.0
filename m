From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [PATCH] select congestion control with one sysctl
Date: Sat, 26 Feb 2005 06:41:34 -0300
Message-ID: <39e6f6c70502260141112f5ab6@mail.gmail.com>
References: <421CF5E5.1060606@ev-en.org>
	 <20050223135732.39e62c6c.davem@davemloft.net>
	 <421D1E66.5090301@osdl.org>
Reply-To: acme@conectiva.com.br
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Baruch Even <baruch@ev-en.org>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, yee-ting.li@nuim.ie, doug.leith@nuim.ie
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <421D1E66.5090301@osdl.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Feb 2005 16:23:02 -0800, Stephen Hemminger
<shemminger@osdl.org> wrote:
> David S. Miller wrote:
> 
> >For the millionth time, you can't just delete the existing sysctls.
> >That is a user visisble interface.
> >
> >Instead, you have to make them at least appear to select a
> >single congestion control algorithm as I stated in the
> >following posting:
> >
> >http://marc.theaimsgroup.com/?l=linux-kernel&m=110909973530321&w=2
> >
> >
> I am heading in a different direction with making the TCP congestion
> protocols
> a real infrastructure.  After the initial version gets done, then I will
> go back
> and add compatiablity interface hooks as required.

Wheee! Now I just have to finish this client project and see what you come
up with to see if it fits what I need for the selectable DCCP congestion control
stuff 8)

-- 
- Arnaldo
