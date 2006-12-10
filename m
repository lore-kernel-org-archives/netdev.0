From: "Jeff Bailey" <jbailey@raspberryginger.com>
Subject: Re: [NETLINK]: Schedule removal of old macros exported to userspace
Date: Sat, 9 Dec 2006 20:42:45 -0500
Message-ID: <5b2e36650612091742u70188d90l25e91c33468a0c0a@mail.gmail.com>
References: <20061208.164345.71119524.davem@davemloft.net> 	 <20061208.171455.11932070.davem@davemloft.net> 	 <20061209103953.GN8693@postel.suug.ch> 	 <20061209.134552.71105673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, drow@false.org, stefan@loplof.de, dwmw2@infradead.org,  	joseph@codesourcery.com, netdev@vger.kernel.org,  	libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <libc-alpha-return-19651-glibc-alpha=m.gmane.org@sourceware.org>
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061209.134552.71105673.davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

On 09/12/06, David Miller <davem@davemloft.net> wrote:
> You can't deprecate stuff visible to userspace, sorry Thomas,
> we just can't do it.
>
> You can migrate people to "better" interfaces, but you can't
> pull the rug out from anyone once things like this are visible
> to userspace.  It's permanently there, and we have to live with
> that.

Is there some way of marking it so that newer architectures that come
on don't wind up with that export?  That way at least as newer
machines and arches come out, they don't have to carry the oldest
baggage.  As the oldest architectures eventually get dropped, cruft
can be removed.

-- 
Jeff Bailey - http://www.raspberryginger.com/jbailey/
