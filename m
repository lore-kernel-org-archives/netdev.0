From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 1/3] net: Make interface aliases available for general
 usage
Date: Sun, 11 Jan 2015 23:43:48 +0100
Message-ID: <54B2FCA4.50501@nod.at>
References: <1421009571-5279-1-git-send-email-richard@nod.at>	<1421009571-5279-2-git-send-email-richard@nod.at> <20150111144039.426f0c48@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	john.fastabend@gmail.com, herbert@gondor.apana.org.au,
	vyasevic@redhat.com, jiri@resnulli.us, vfalico@gmail.com,
	therbert@google.com, edumazet@google.com, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, kuznet@ms2.inr.ac.ru, kadlec@blackhole.kfki.hu,
	kaber@trash.net, pablo@netfilter.org, kay@vrfy.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150111144039.426f0c48@urahara>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

Am 11.01.2015 um 23:40 schrieb Stephen Hemminger:
> On Sun, 11 Jan 2015 21:52:49 +0100
> Richard Weinberger <richard@nod.at> wrote:
> 
>> Allow interface aliases to be used as regular interfaces.
>> Such that a command sequence like this one works:
>> $ ip l set eth0 alias internet
>> $ ip a s internet
>> $ tcpdump -n -i internet
>>
>> Signed-off-by: Richard Weinberger <richard@nod.at>
> 
> There is already a ifalias and it is used by SNMP.
> But the common practice is to put longer descriptive names which aren't going
> to be usable and there is no requirement that they be unique.

Actually I'm using ifalias. This patch just exposes it.

> I think you can't do this without breaking some of our users.

My idea was that udev will not set the alias if already one is used.

Thanks,
//richard
