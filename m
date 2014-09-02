From: Cong Wang <cwang@twopensource.com>
Subject: Re: RTNL: assertion failed at net/ipv6/addrconf.c (1699)
Date: Tue, 2 Sep 2014 11:37:08 -0700
Message-ID: <CAHA+R7N6ZApvDi+JPW+2V98Rfm==jv1ES7xB0pzMDZx=q53rkA@mail.gmail.com>
References: <CA+ydwtoDwQVg_BWrxxdpUyJ7Up60GtxTCLYe_5vFdV2td_kGhQ@mail.gmail.com>
	<CAHA+R7MZCDGRhSf=UuVCGQvNo03wVziZQB_X30rwNf6hmHipQA@mail.gmail.com>
	<20140829195339.GA9780@kria>
	<1409363489.2980.17.camel@localhost>
	<CAHA+R7ODa+LrdwSrS7HcBfwwq8_fpj-Ld0OCDtcOqkpCdZCvxg@mail.gmail.com>
	<1409680684.972417.162793869.03CF8A61@webmail.messagingengine.com>
	<CAHA+R7Mwy1SCpEUgGf9BdLEro6N-3t89KU=xL0iuzgOppXELrQ@mail.gmail.com>
	<1409681487.26422.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7PY=Pu7VKA3wp1DxeJRckxPNWL-xfv2XXkpaY935kt61A@mail.gmail.com>
	<1409682093.26422.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Tommi Rantala <tt.rantala@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, trinity@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <trinity-owner@vger.kernel.org>
In-Reply-To: <1409682093.26422.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 2, 2014 at 11:21 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-09-02 at 11:15 -0700, Cong Wang wrote:
>
>> That is what we do when backporting patches, I can do that if David asks
>> me to backport it, but you know for netdev that is David's work.
>>
>> (I am not saying I don't want to help him, I just want to point out the fact.
>> I am very pleased to help David for stable backports as long as he asks)
>
> Problem is : your patch submission do not identify bug origin.
>
> You claim you want to help, but you do not provide the basic thing that
> _really_ helps.
>
> The proper way to identify bug origin is to add in the headers one
> line :
>
> Fixes: 12-digit-SHA1 ("patch title")
>

Since when "Fixes:" tag becomes mandatory for a stable patch?
At least netdev-FAQ is not updated. ;-) I 100% agree "Fixes:"
is helpful when backporting patches, but it is not mandatory currently.

For this patch, I was too lazy to dig the history, it looks like this is
caused by the following commit:

commit c15b1ccadb323ea50023e8f1cca2954129a62b51
Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date:   Thu Mar 27 18:28:07 2014 +0100

    ipv6: move DAD and addrconf_verify processing to workqueue

Thanks.
