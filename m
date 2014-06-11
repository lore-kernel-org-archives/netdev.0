From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 3/5] ipv6: consider net.ipv6.conf.all sysctls
 when making decisions
Date: Wed, 11 Jun 2014 15:32:25 -0700 (PDT)
Message-ID: <20140611.153225.671693159592497903.davem@davemloft.net>
References: <1402417153-2551-4-git-send-email-milos.vyletel@gmail.com>
	<20140610101334.565bc484@nehalam.linuxnetplumber.net>
	<CAAFXRd1Stuyj2t8Oinr6SQysGbMJKPpY5qe=mO_m0xKR1eSjOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, amwang@redhat.com,
	netdev@vger.kernel.org, oliver@neukum.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	pshelar@nicira.com, nicolas.dichtel@6wind.com,
	mike.rapoport@ravellosystems.com, dborkman@redhat.com,
	ogerlitz@mellanox.com, therbert@google.com,
	hannes@stressinduktion.org, florent.fourcot@enst-bretagne.fr,
	edumazet@google.com, Paul.Durrant@citrix.com,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: milos.vyletel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAFXRd1Stuyj2t8Oinr6SQysGbMJKPpY5qe=mO_m0xKR1eSjOQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Milos Vyletel <milos.vyletel@gmail.com>
Date: Tue, 10 Jun 2014 13:49:35 -0400

> On Tue, Jun 10, 2014 at 1:13 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>> On Tue, 10 Jun 2014 12:19:11 -0400
>> Milos Vyletel <milos.vyletel@gmail.com> wrote:
>>
>>> As it is right now net.ipv6.conf.all.* are mostly ignored and instead
>>> we're only making decisions based on interface specific settings. These
>>> settings are coppied from net.ipv6.conf.default and changing either all
>>> or default settings have no effect.
>>
>> Although this is the right idea conceptually, it risks creating unhappy
>> users because it changes the semantics of the API. This will probably break
>> somebody's configuration.
> 
> You're right but in this case I feel we are moving in the right
> direction. While the
> behavior will change in some cases this change is only adding well known ipv4
> behavior for ipv6 sysctls. In fact documentation briefly mentioned that
> net.ipv6.conf.all.* should change all the interface-specific settings
> but that was
> not the case until now.

You can't just break things on people, no matter how much you think the
current behavior is "poorly designed", "inconsistent with other areas of
the networking", etc.  None of those things matter if you have to break
things on people to "fix" it.

I'm not applying this series, sorry.
