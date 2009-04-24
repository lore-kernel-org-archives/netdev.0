From: Patrick McHardy <kaber@trash.net>
Subject: Re: IMQ bug: kernel reboot immediately
Date: Fri, 24 Apr 2009 17:19:43 +0200
Message-ID: <49F1D88F.500@trash.net>
References: <20090423084323.GA5696@ff.dom.local> <beb91d720904231632m2a66768dy95f1df1491d97f5b@mail.gmail.com> 	<49F1D16A.8050003@trash.net> <200904241755.09198.denys@visp.net.lb> <beb91d720904240814x56a928a5u5345e572c701fa90@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jarek Poplawski <jarkao2@gmail.com>,
	"Y. D." <duyuyang@gmail.com>, netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Salatiel Filho <salatiel.filho@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <beb91d720904240814x56a928a5u5345e572c701fa90@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Salatiel Filho wrote:
> On Fri, Apr 24, 2009 at 11:55, Denys Fedoryschenko <denys@visp.net.lb> wrote:
>> On Friday 24 April 2009 17:49:14 Patrick McHardy wrote:
>>> There is DRR since a couple of versions. Combined with the
>>> flow classifier, it should provide the same functionality
>>> as ESFQ.
>> I think it is even better, as soon as you understand it, it is very intuitive
>> to understand and transparent, how it works.
>>
> 
> I am just curious , is there a qdisc in mainline that behaves similar
> to wrr [weight round robin] ?
> http://www.zz9.dk/wrr

DRR. But it can't do those strange load-balancing hacks.
