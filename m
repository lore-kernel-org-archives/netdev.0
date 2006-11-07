From: "Zhao Xiaoming" <xiaoming.nj@gmail.com>
Subject: Re: ZONE_NORMAL memory exhausted by 4000 TCP sockets
Date: Tue, 7 Nov 2006 14:08:31 +0800
Message-ID: <f55850a70611062208l214c1a62vc8ec9133eaca2e5e@mail.gmail.com>
References: <f55850a70611052207j384e1d3flaf40bb9dd74df7c5@mail.gmail.com>
	 <200611061022.57840.dada1@cosmosbay.com>
	 <f55850a70611060146o1b2adcabq8c1313f6711f3f4e@mail.gmail.com>
	 <200611061433.50912.dada1@cosmosbay.com>
	 <f55850a70611061848g5f316399oe877a38705e7f99b@mail.gmail.com>
	 <45501F60.4070606@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"Linux Netdev List" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.204]:34633 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1754071AbWKGGIc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 01:08:32 -0500
Received: by nz-out-0102.google.com with SMTP id z3so1038026nzf
        for <netdev@vger.kernel.org>; Mon, 06 Nov 2006 22:08:32 -0800 (PST)
To: "Eric Dumazet" <dada1@cosmosbay.com>
In-Reply-To: <45501F60.4070606@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/7/06, Eric Dumazet <dada1@cosmosbay.com> wrote:
> Zhao Xiaoming a =E9crit :
> > On 11/6/06, Eric Dumazet <dada1@cosmosbay.com> wrote:
> >> In fact, your kernel has CONFIG_4KSTACKS, kernel thread stacks use=
 4K
> >> instead
> >> of 8K.
> >>
> >> If you want to increase LOWMEM, (and keep 32bits kernel), you can =
chose a
> >> 2G/2G user/kernel split, instead of the 3G/1G default split.
> >> (see config : CONFIG_VMSPLIT_2G)
> >>
> >> Eric
>
> > Thank you for your advice. I know increase LOMEM could be help, but
> > now my concern is why I lose my 500M bytes memory after excluding a=
ll
> > known memory cost.
>
> Unfortunatly you dont provide very much details.
> AFAIK you didnt even gave whcih version of linux you run, which progr=
ams you
> run...
> You keep answering where you 'lost' your mem, it's quite buging.
> Maybe some Oracles on this list will see the light for you, before ex=
changing
> 100 mails with you ?
>
>
I think I aready gave the kernel version and introduced my application
in the first post. What are the further details you want? The reason I
keep asking for the 'lost mem' is that I want to focus on the problem,
not the workarrounds that may lead to further problems if I keep
increasing the concurrent scale.
Anyway, since the problem is already solved (see my last post), I'd
like to thank you for the help.

Xiaoming.
