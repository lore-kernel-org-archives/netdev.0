From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: IMQ bug: kernel reboot immediately
Date: Thu, 23 Apr 2009 12:11:04 +0000
Message-ID: <20090423121104.GC6809@ff.dom.local>
References: <20090423084323.GA5696@ff.dom.local> <49F040E8.80402@trash.net> <alpine.LSU.2.00.0904231223050.18687@fbirervta.pbzchgretzou.qr> <49F042E7.7060900@trash.net> <beb91d720904230412j4dea4034o61f2d0682ff76d1a@mail.gmail.com> <49F04F6B.7010709@trash.net> <20090423114019.GB6809@ff.dom.local> <49F05502.7050504@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Salatiel Filho <salatiel.filho@gmail.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	"Y. D." <duyuyang@gmail.com>, netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49F05502.7050504@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 23, 2009 at 01:46:10PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> On Thu, Apr 23, 2009 at 01:22:19PM +0200, Patrick McHardy wrote:
>> ...
>>> Currently not, the conntrack association is done at a later point.
>>> We could add a classifier or TC action that performs the lookup
>>> during ingress classification.
>>
>> BTW, some time ago I started to wonder how safe are those various
>> ingress activities wrt. invalid packets, dropped later in ip_rcv().
>
> Leaving aside the ipt action, I'm not aware of any problems caused
> by ingress classification. Could you be more specific?

There is nothing specific yet. I hope these other classifiers and
actions aren't mislead too much to go astray.

Jarek P.
